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

      has_many :policy_hostgroups, :dependent => :destroy
      has_many :hostgroups, :through => :policy_hostgroups, :uniq => true

      validates :name, :presence => true, :uniqueness => true, :no_whitespace => true
      validate :ensure_needed_puppetclasses
      # validates :weekday, in
      # validates :period, in
      SCAP_PUPPET_CLASS = 'openscap::xccdf::foreman_audit'

      after_save :assign_policy_to_hostgroups
      # before_destroy - ensure that the policy has no hostgroups, or classes

      scoped_search :on => :name, :complete_value => true

      default_scope {
        with_taxonomy_scope do
          order("scaptimony_policies.name")
        end
      }
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

    def step_index
      steps.index(current_step) + 1
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

    # override to not query join with hostgroups.
    def hostgroup_ids
      policy_hostgroups.pluck("DISTINCT hostgroup_id")
    end

    def used_hostgroup_ids
      Scaptimony::PolicyHostgroup.where(['policy_id <> ?', id]).pluck('DISTINCT hostgroup_id')
    end

    def assign_hosts(hosts)
      assign_assets hosts.map &:get_asset
    end

    private

    def ensure_needed_puppetclasses
      unless Puppetclass.find_by_name(SCAP_PUPPET_CLASS)
        errors[:base] << _("Required Puppet class %{class} is not found, please ensure it imported first.") % {:class => SCAP_PUPPET_CLASS}
      end
    end

    def assign_policy_to_hostgroups
      if hostgroups
        puppetclass = Puppetclass.find_by_name(SCAP_PUPPET_CLASS)
        hostgroups.each do |hostgroup|
          hostgroup.puppetclasses << puppetclass unless hostgroup.puppetclasses.include? puppetclass
          populate_overrides(puppetclass, hostgroup)
        end
      end
    end

    def populate_overrides(puppetclass, hostgroup)
      overrides = puppetclass.class_params.where(:override => true)
      overrides.each do |override|
        override_value = if override.key == 'foreman_proxy'
                           hostgroup.puppet_proxy.url if hostgroup.puppet_proxy
                         else
                           self.send(override.key)
                         end
        if override_value.present?
          lookup_value = LookupValue.where(:match => hostgroup.lookup_value_match, :lookup_key_id => override.id).first_or_create
          lookup_value.update_attribute(:value, override_value)
        end
      end
    end
  end
end
