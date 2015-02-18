#
# Copyright (c) 2014 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 3 (GPLv3). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv3
# along with this software; if not, see http://www.gnu.org/licenses/gpl.txt
#

module ForemanOpenscap
  module PolicyExtensions
    extend ActiveSupport::Concern

    include Authorizable
    include Taxonomix

    included do
      attr_accessible :location_ids, :organization_ids, :current_step, :hostgroup_ids
      attr_writer :current_step

      SCAP_PUPPET_CLASS = 'foreman_scap_client'
      POLICIES_CLASS_PARAMETER = 'policies'
      SERVER_CLASS_PARAMETER = 'server'

      validates :name, :presence => true, :uniqueness => true, :format => { without: /\s/ }
      validate :ensure_needed_puppetclasses
      validates :period, :inclusion => {:in => %w[weekly monthly custom]},
                :if => Proc.new { | policy | policy.new_record? ? policy.step_index > 3 : !policy.id.blank? }
      validates :weekday, :inclusion => {:in => Date::DAYNAMES.map(&:downcase)},
                :if => Proc.new { | policy | policy.new_record? ? policy.step_index > 3 && policy.period == 'weekly' : !policy.id.blank? }
      validates :day_of_month, :numericality => {:greater_than => 0, :less_than => 32},
                :if => Proc.new { | policy | policy.new_record? ? policy.step_index > 3 && policy.period == 'monthly' : !policy.id.blank? }
      validate :valid_cron_line
      validate :ensure_period_specification_present


      after_save :assign_policy_to_hostgroups
      # before_destroy - ensure that the policy has no hostgroups, or classes

      default_scope {
        with_taxonomy_scope do
          order("scaptimony_policies.name")
        end
      }
    end

    def hostgroup_ids
      assets.where(:assetable_type => 'Hostgroup').pluck(:assetable_id)
    end

    def hostgroup_ids=(ids)
      hostgroup_assets = []
      ids.reject(&:empty?).map do |id|
        hostgroup_assets << assets.where(:assetable_type => 'Hostgroup', :assetable_id => id).first_or_create!
      end
      self.assets = hostgroup_assets
    end

    def hostgroups
      Hostgroup.find(hostgroup_ids)
    end

    def hostgroups=(hostgroups)
      hostgroup_ids = hostgroups.map(&:id).map(&:to_s)
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
      steps[steps.index(current_step) + 1 ]
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
              'taxable_taxonomies.taxable_type' => 'Scaptimony::Policy',
              'taxable_taxonomies.taxable_id' => id).pluck("#{Location.arel_table.name}.id")
    end

    def used_organization_ids
      Organization.joins(:taxable_taxonomies).where(
              'taxable_taxonomies.taxable_type' => 'Scaptimony::Policy',
              'taxable_taxonomies.taxable_id' => id).pluck("#{Location.arel_table.name}.id")
    end

    def used_hostgroup_ids
      []
    end

    def assign_hosts(hosts)
      assign_assets hosts.map &:get_asset
    end

    def to_enc
      {
        'id' => self.id,
        'profile_id' => self.scap_content_profile.try(:profile_id) || '',
        'content_path' => "/var/lib/openscap/content/#{self.scap_content.digest}.xml",
      }.merge(period_enc)
    end

    private

    def period_enc
      # get crontab expression as an array (minute hour day_of_month month day_of_week)
      cron_parts = case period
        when 'weekly'
          [ '0', '1', '*', '*', weekday_number.to_s ]
        when 'monthly'
          [ '0', '1', day_of_month.to_s, '*', '*']
        when 'custom'
          cron_line_split
        else
          raise 'invalid period specification'
      end

      {
        'minute' => cron_parts[0],
        'hour' => cron_parts[1],
        'monthday' => cron_parts[2],
        'month' => cron_parts[3],
        'weekday' => cron_parts[4],
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

      unless policies_param = puppetclass.class_params.where(:key => POLICIES_CLASS_PARAMETER).first
        errors[:base] << _("Puppet class %{class} does not have %{parameter} class parameter.") % {:class => SCAP_PUPPET_CLASS, :parameter => POLICIES_CLASS_PARAMETER}
        return false
      end

      policies_param.override = true
      policies_param.key_type = 'array'
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
      puppetclass.class_params.where(:override => true, :key => SERVER_CLASS_PARAMETER).each do |override|
        if hostgroup.puppet_proxy && (url = hostgroup.puppet_proxy.url).present?
          lookup_value = LookupValue.where(:match => "hostgroup=#{hostgroup.to_label}", :lookup_key_id => override.id).first_or_initialize
          puppet_proxy_fqdn = URI.parse(url).host
          lookup_value.update_attribute(:value, puppet_proxy_fqdn)
        end
      end
    end
  end
end
