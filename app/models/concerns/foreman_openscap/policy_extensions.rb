#
# Copyright (c) 2014 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 3 (GPLv3). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv3
# along with this software; if not, see http://www.gnu.org/licenses/gpl.txt
#

require 'scaptimony/policy'

module ForemanOpenscap
  module PolicyExtensions
    extend ActiveSupport::Concern
    include Authorizable
    include Taxonomix
    included do
      attr_accessible :location_ids, :organization_ids, :current_step, :hostgroup_ids
      attr_writer :current_step

      has_many :policy_hostgroups, :dependent => :destroy
      has_many :hostgroups, :through => :policy_hostgroups

      after_save :assign_policy_to_hostgroups

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

    def assign_hosts(hosts)
      assign_assets hosts.map &:get_asset
    end

    private

    def assign_policy_to_hostgroups
      puppetclass = Puppetclass.find('openscap::xccdf::foreman_audit')
      ## @TODO: Handle puppetclass not found
      hostgroups.each do |hostgroup|
        hostgroup.puppetclasses << puppetclass unless hostgroup.puppetclasses.include? puppetclass
        populate_overrides(puppetclass, hostgroup)
      end
    end

    def populate_overrides(puppetclass, hostgroup)
      overrides = puppetclass.class_params.where(:override => true)
      overrides.each do |override|
        if override.key == 'foreman_proxy'
          # override_value = hostgroup.puppet_proxy.url
          next
        else
          override_value = self.send(override.key)
        end
        p "############## #{override_value}"
        unless override_value.blank?
          p "OVERRIDE ID #{override.id}"
          p "HG:::::::::::::: #{hostgroup.to_label}"
          lookup_value = LookupValue.where(:match => "hostgroup=#{hostgroup.to_label}", :lookup_key_id => override.id).first_or_create
          lookup_value.update_attribute(:value, override_value)
          hostgroup.lookup_values << lookup_value
        end

      end
    end
  end
end
