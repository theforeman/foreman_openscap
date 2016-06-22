module ForemanOpenscap
  class Policy < ActiveRecord::Base
    include Authorizable
    include Taxonomix
    attr_accessible :description, :name, :period, :scap_content_id, :scap_content_profile_id,
                    :weekday, :day_of_month, :cron_line, :location_ids, :organization_ids,
                    :current_step, :hostgroup_ids
    attr_writer :current_step

    belongs_to :scap_content
    belongs_to :scap_content_profile
    has_many :policy_arf_reports
    has_many :arf_reports, :through => :policy_arf_reports, :dependent => :destroy
    has_many :asset_policies
    has_many :assets, :through => :asset_policies

    scoped_search :on => :name, :complete_value => true

    SCAP_PUPPET_CLASS        = 'foreman_scap_client'
    POLICIES_CLASS_PARAMETER = 'policies'
    SERVER_CLASS_PARAMETER   = 'server'
    PORT_CLASS_PARAMETER     = 'port'

    validates :name, :presence => true, :uniqueness => true, :format => { :without => /\s/ }
    validate :ensure_needed_puppetclasses
    validates :period, :inclusion => {:in => %w(weekly monthly custom)},
              :if                 => Proc.new { |policy| policy.new_record? ? policy.step_index > 3 : !policy.id.blank? }
    validates :weekday, :inclusion => {:in => Date::DAYNAMES.map(&:downcase)},
              :if                  => Proc.new { |policy| policy.period == 'weekly' && (policy.new_record? ? policy.step_index > 3 : !policy.id.blank?) }
    validates :day_of_month, :numericality => {:greater_than => 0, :less_than => 32},
              :if                          => Proc.new { |policy| policy.period == 'monthly'&& (policy.new_record? ? policy.step_index > 3 : !policy.id.blank?) }
    validate :valid_cron_line
    validate :ensure_period_specification_present


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
      if scap_content.nil? || scap_content_profile.nil?
        return ("<h2>%s</h2>" % (_('Cannot generate HTML guide for %{scap_content}/%{profile}') %
          { :scap_content => self.scap_content, :profile => self.scap_content_profile })).html_safe
      end

      if (proxy = scap_content.proxy_url)
        api = ProxyAPI::Openscap.new(:url => proxy)
      else
        return ("<h2>%s</h2>" % _('No valid OpenSCAP proxy server found.')).html_safe
      end

      api.policy_html_guide(scap_content.scap_file, scap_content_profile.profile_id)
    end

    def hostgroup_ids
      assets.where(:assetable_type => 'Hostgroup').pluck(:assetable_id)
    end

    def hostgroup_ids=(ids)
      hostgroup_assets = []
      ids.reject(&:empty?).map do |id|
        hostgroup_assets << assets.where(:assetable_type => 'Hostgroup', :assetable_id => id).first_or_create!
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

    def steps
      base_steps = ['Create policy', 'SCAP Content', 'Schedule']
      base_steps << 'Locations' if SETTINGS[:locations_enabled]
      base_steps << 'Organizations' if SETTINGS[:organizations_enabled]
      base_steps << 'Hostgroups' #always be last.
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
        'taxable_taxonomies.taxable_id'   => id).pluck("#{Location.arel_table.name}.id")
    end

    def used_organization_ids
      Organization.joins(:taxable_taxonomies).where(
        'taxable_taxonomies.taxable_type' => 'ForemanOpenscap::Policy',
        'taxable_taxonomies.taxable_id'   => id).pluck("#{Location.arel_table.name}.id")
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
        'profile_id'    => self.scap_content_profile.try(:profile_id) || '',
        'content_path'  => "/var/lib/openscap/content/#{self.scap_content.digest}.xml",
        'download_path' => "/compliance/policies/#{self.id}/content" # default to proxy path
      }.merge(period_enc)
    end

    private

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
                     fail 'invalid period specification'
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
      unless puppetclass = Puppetclass.find_by_name(SCAP_PUPPET_CLASS)
        errors[:base] << _("Required Puppet class %{class} is not found, please ensure it imported first.") % {:class => SCAP_PUPPET_CLASS}
        return false
      end

      unless policies_param = puppetclass.class_params.find_by_key(POLICIES_CLASS_PARAMETER)
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
      cron_line.split(' ')
    end

    def valid_cron_line
      return true if period != 'custom' || step_index != 4

      unless cron_line_split.size == 5
        errors[:base] << _("Cron line does not consist of 5 parts separated by space")
        return false
      end
    end

    def ensure_period_specification_present
      return true if period.blank? || step_index != 4

      error = nil
      error = _("You must fill weekday") if weekday.blank? && period == 'weekday'
      error = _("You must fill day of month") if day_of_month.blank? && period == 'monthly'
      error = _("You must fill cron line") if cron_line.blank? && period == 'custom'
      if error
        errors[:base] << error
        return false
      end
    end

    def assign_policy_to_hostgroups
      if hostgroups.any?
        puppetclass = Puppetclass.find_by_name(SCAP_PUPPET_CLASS)
        hostgroups.each do |hostgroup|
          hostgroup.puppetclasses << puppetclass unless hostgroup.puppetclasses.include? puppetclass
          populate_overrides(puppetclass, hostgroup)
        end
      end
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
