require 'rack/utils'
module ForemanOpenscap
  class Policy < ActiveRecord::Base
    include Authorizable
    include Taxonomix
    attr_writer :current_step, :wizard_initiated
    audited

    belongs_to :scap_content
    belongs_to :scap_content_profile
    belongs_to :tailoring_file
    belongs_to :tailoring_file_profile, :class_name => ForemanOpenscap::ScapContentProfile
    has_many :policy_arf_reports
    has_many :arf_reports, :through => :policy_arf_reports, :dependent => :destroy
    has_many :asset_policies
    has_many :assets, :through => :asset_policies, :as => :assetable, :dependent => :destroy

    scoped_search :on => :name, :complete_value => true

    SCAP_PUPPET_CLASS        = 'foreman_scap_client'.freeze
    POLICIES_CLASS_PARAMETER = 'policies'.freeze
    SERVER_CLASS_PARAMETER   = 'server'.freeze
    PORT_CLASS_PARAMETER     = 'port'.freeze

    before_validation :update_period_attrs

    validates :name, :presence => true, :uniqueness => true, :length => { :maximum => 255 }
    validate :ensure_needed_puppetclasses
    validates :period, :inclusion => {:in => %w[weekly monthly custom], :message => _('is not a valid value')},
              :if => Proc.new { |policy| policy.should_validate?('Schedule') }

    validates :scap_content_id, presence: true, if: Proc.new { |policy| policy.should_validate?('SCAP Content') }
    validate :matching_content_profile, if: Proc.new { |policy| policy.should_validate?('SCAP Content') }

    validate :valid_cron_line, :valid_weekday, :valid_day_of_month, :valid_tailoring, :valid_tailoring_profile
    after_save :assign_policy_to_hostgroups
    # before_destroy - ensure that the policy has no hostgroups, or classes

    default_scope do
      with_taxonomy_scope do
        order("foreman_openscap_policies.name")
      end
    end

    def assign_assets(a)
      self.asset_ids = (self.asset_ids + a.collect(&:id)).uniq
    end

    def to_html
      if scap_content.nil?
        return html_error_message(_('Cannot generate HTML guide, scap content is missing.'))
      end

      if (proxy = scap_content.proxy_url)
        api = ProxyAPI::Openscap.new(:url => proxy)
      else
        return html_error_message(_('Cannot generate HTML guide, no valid OpenSCAP proxy server found.'))
      end

      api.policy_html_guide(scap_content.scap_file, scap_content_profile.try(:profile_id))
    end

    def hostgroup_ids
      assets.where(:assetable_type => 'Hostgroup').pluck(:assetable_id)
    end

    def hostgroup_ids=(ids)
      hostgroup_assets = []
      ids.reject { |id| id.respond_to?(:empty?) && id.empty? }.map do |id|
        hostgroup_assets << assets.where(:assetable_type => 'Hostgroup', :assetable_id => id).first_or_initialize
      end
      existing_host_assets = self.assets.where(:assetable_type => 'Host::Base')
      self.assets = existing_host_assets + hostgroup_assets
    end

    def hostgroups
      Hostgroup.find(hostgroup_ids)
    end

    def hostgroups=(hostgroups)
      hostgroup_ids = hostgroups.map(&:id).map(&:to_s)
    end

    def host_ids
      assets.where(:assetable_type => 'Host::Base').pluck(:assetable_id)
    end

    def hosts
      Host.where(:id => host_ids)
    end

    def hosts=(hosts)
      host_ids = hosts.map(&:id).map(&:to_s)
    end

    def step_to_i(step_name)
      steps.index(step_name) + 1
    end

    def steps
      base_steps = [N_('Create policy'), N_('SCAP Content'), N_('Schedule')]
      base_steps << N_('Locations') if SETTINGS[:locations_enabled]
      base_steps << N_('Organizations') if SETTINGS[:organizations_enabled]
      base_steps << N_('Hostgroups') #always be last.
    end

    def current_step
      @current_step || steps.first
    end

    def previous_step
      steps[steps.index(current_step) - 1]
    end

    def next_step
      steps[steps.index(current_step) + 1]
    end

    def rewind_step
      @current_step = previous_step
    end

    def first_step?
      current_step == steps.first
    end

    def last_step?
      current_step == steps.last
    end

    def wizard_completed?
      new_record? && current_step.blank?
    end

    def step_index
      wizard_completed? ? steps.index(steps.last) : steps.index(current_step) + 1
    end

    def scan_name
      name
    end

    def used_location_ids
      Location.joins(:taxable_taxonomies).where(
        'taxable_taxonomies.taxable_type' => 'ForemanOpenscap::Policy',
        'taxable_taxonomies.taxable_id'   => id
      ).pluck("#{Location.arel_table.name}.id")
    end

    def used_organization_ids
      Organization.joins(:taxable_taxonomies).where(
        'taxable_taxonomies.taxable_type' => 'ForemanOpenscap::Policy',
        'taxable_taxonomies.taxable_id'   => id
      ).pluck("#{Location.arel_table.name}.id")
    end

    def used_hostgroup_ids
      []
    end

    def assign_hosts(hosts)
      assign_assets hosts.map &:get_asset
    end

    def unassign_hosts(hosts)
      host_asset_ids = ForemanOpenscap::Asset.where(:assetable_type => 'Host::Base', :assetable_id => hosts.map(&:id)).pluck(:id)
      self.asset_ids = self.asset_ids - host_asset_ids
    end

    def to_enc
      {
        'id'            => self.id,
        'profile_id'    => profile_for_scan,
        'content_path'  => "/var/lib/openscap/content/#{self.scap_content.digest}.xml",
        'tailoring_path' => tailoring_file ? "/var/lib/openscap/tailoring/#{self.tailoring_file.digest}.xml" : '',
        'download_path' => "/compliance/policies/#{self.id}/content/#{scap_content.digest}",
        'tailoring_download_path' => tailoring_file ? "/compliance/policies/#{self.id}/tailoring/#{tailoring_file.digest}" : ''
      }.merge(period_enc)
    end

    def to_enc_legacy
      to_enc.tap { |hash| hash['download_path'] = "/compliance/policies/#{self.id}/content" }
    end

    def should_validate?(step_name)
      if new_record? && wizard_initiated?
        step_index > step_to_i(step_name)
      elsif new_record? && !wizard_initiated?
        true
      else
        persisted?
      end
    end

    def wizard_initiated?
      @wizard_initiated
    end

    def update_period_attrs
      case period
      when 'monthly'
        erase_period_attrs(%w[cron_line weekday])
      when 'weekly'
        erase_period_attrs(%w[cron_line day_of_month])
      when 'custom'
        erase_period_attrs(%w[weekday day_of_month])
      end
    end

    private

    def html_error_message(message)
      error_message = '<div class="alert alert-danger"><span class="pficon pficon-error-circle-o"></span><strong>' <<
        message <<
        '</strong></div>'
      error_message.html_safe
    end

    def erase_period_attrs(attrs)
      attrs.each { |attr| self.public_send("#{attr}=", nil) }
    end

    def period_enc
      # get crontab expression as an array (minute hour day_of_month month day_of_week)
      cron_parts = case period
                   when 'weekly'
                     ['0', '1', '*', '*', weekday_number.to_s]
                   when 'monthly'
                     ['0', '1', day_of_month.to_s, '*', '*']
                   when 'custom'
                     cron_line_split
                   else
                     raise 'invalid period specification'
                   end

      {
        'minute'   => cron_parts[0],
        'hour'     => cron_parts[1],
        'monthday' => cron_parts[2],
        'month'    => cron_parts[3],
        'weekday'  => cron_parts[4],
      }
    end

    def weekday_number
      # 0 is sunday, 1 is monday in cron, while DAYS_INTO_WEEK has 0 as monday, 6 as sunday
      (Date::DAYS_INTO_WEEK.with_indifferent_access[weekday] + 1) % 7
    end

    def ensure_needed_puppetclasses
      unless puppetclass = Puppetclass.find_by(name: SCAP_PUPPET_CLASS)
        errors[:base] << _("Required Puppet class %{class} is not found, please ensure it imported first.") % {:class => SCAP_PUPPET_CLASS}
        return false
      end

      unless policies_param = puppetclass.class_params.find_by(key: POLICIES_CLASS_PARAMETER)
        errors[:base] << _("Puppet class %{class} does not have %{parameter} class parameter.") % {:class => SCAP_PUPPET_CLASS, :parameter => POLICIES_CLASS_PARAMETER}
        return false
      end

      policies_param.override      = true
      policies_param.key_type      = 'array'
      policies_param.default_value = '<%= @host.policies_enc %>'

      if policies_param.changed? && !policies_param.save
        errors[:base] << _("%{parameter} class parameter for class %{class} could not be configured.") % {:class => SCAP_PUPPET_CLASS, :parameter => POLICIES_CLASS_PARAMETER}
        return false
      end
    end

    def cron_line_split
      cron_line.to_s.split(' ')
    end

    def valid_cron_line
      if period == 'custom' && should_validate?('Schedule')
        errors.add(:cron_line, _("does not consist of 5 parts separated by space")) unless cron_line_split.size == 5
      end
    end

    def valid_weekday
      if period == 'weekly' && should_validate?('Schedule')
        errors.add(:weekday, _("is not a valid value")) unless Date::DAYNAMES.map(&:downcase).include? weekday
      end
    end

    def valid_day_of_month
      if period == 'monthly' && should_validate?('Schedule')
        errors.add(:day_of_month, _("must be between 1 and 31")) if !day_of_month || (day_of_month < 1 || day_of_month > 31)
      end
    end

    def valid_tailoring
      errors.add(:tailoring_file_id, _("must be present when tailoring file profile present")) if tailoring_file_profile_id && !tailoring_file_id
      errors.add(:tailoring_file_profile_id, _("must be present when tailoring file present")) if !tailoring_file_profile_id && tailoring_file_id
    end

    def valid_tailoring_profile
      if tailoring_file && tailoring_file_profile && !ScapContentProfile.where(:tailoring_file_id => tailoring_file_id).include?(tailoring_file_profile)
        errors.add(:tailoring_file_profile, _("does not come from selected tailoring file"))
      end
    end

    def matching_content_profile
      if scap_content_id && scap_content_profile_id && !ScapContent.find(scap_content_id).scap_content_profile_ids.include?(scap_content_profile_id)
        errors.add(:scap_content_id, _("does not have the selected SCAP content profile"))
      end
    end

    def assign_policy_to_hostgroups
      if hostgroups.any?
        puppetclass = find_scap_puppetclass
        hostgroups.each do |hostgroup|
          hostgroup.puppetclasses << puppetclass unless hostgroup.puppetclasses.include? puppetclass
          populate_overrides(puppetclass, hostgroup)
        end
      end
    end

    def profile_for_scan
      if tailoring_file_profile
        tailoring_file_profile.profile_id
      elsif scap_content_profile
        scap_content_profile.profile_id
      else
        ''
      end
    end

    def find_scap_puppetclass
      Puppetclass.find_by(name: SCAP_PUPPET_CLASS)
    end

    def populate_overrides(puppetclass, hostgroup)
      puppetclass.class_params.where(:override => true).find_each do |override|
        next unless hostgroup.puppet_proxy && (url = hostgroup.puppet_proxy.url).present?

        case override.key
        when SERVER_CLASS_PARAMETER
          lookup_value      = LookupValue.where(:match => "hostgroup=#{hostgroup.to_label}", :lookup_key_id => override.id).first_or_initialize
          puppet_proxy_fqdn = URI.parse(url).host
          lookup_value.update_attribute(:value, puppet_proxy_fqdn)
        when PORT_CLASS_PARAMETER
          lookup_value      = LookupValue.where(:match => "hostgroup=#{hostgroup.to_label}", :lookup_key_id => override.id).first_or_initialize
          puppet_proxy_port = URI.parse(url).port
          lookup_value.update_attribute(:value, puppet_proxy_port)
        end
      end
    end
  end
end
