module ForemanOpenscap
  module OvalFacetHostExtensions
    extend ActiveSupport::Concern

    included do
      has_many :oval_policies, :through => :oval_facet, :class_name => 'ForemanOpenscap::OvalPolicy'
    end

    def combined_oval_policies
      combined = oval_policies
      combined += hostgroup.oval_policies + hostgroup.inherited_oval_policies if hostgroup
      combined.uniq
    end
  end
end
