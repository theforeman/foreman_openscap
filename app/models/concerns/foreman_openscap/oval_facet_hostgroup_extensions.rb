module ForemanOpenscap
  module OvalFacetHostgroupExtensions
    extend ActiveSupport::Concern

    include InheritedPolicies

    included do
      has_many :oval_policies, :through => :oval_facet, :class_name => 'ForemanOpenscap::OvalPolicy'

      scoped_search :relation => :oval_policies,
                    :on => :id,
                    :rename => :oval_policy_id,
                    :complete_value => false,
                    :only_explicit => true,
                    :ext_method => :find_by_oval_policy_id,
                    :operators => ['= ']
    end

    def inherited_oval_policies
      find_inherited_policies :oval_policies
    end

    module ClassMethods
      def find_by_oval_policy_id(_key, operator, value)
        conditions = sanitize_sql_for_conditions(["#{::ForemanOpenscap::HostgroupOvalFacetOvalPolicy.table_name}.oval_policy_id #{operator} ?", value])
        hg_ids = ::ForemanOpenscap::Hostgroup::OvalFacet.joins(:hostgroup_oval_facet_oval_policies).where(conditions).pluck(:hostgroup_id)
        { :conditions => ::Hostgroup.arel_table[:id].in(hg_ids).to_sql }
      end
    end
  end
end
