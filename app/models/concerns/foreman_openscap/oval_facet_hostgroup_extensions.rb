module ForemanOpenscap
  module OvalFacetHostgroupExtensions
    extend ActiveSupport::Concern

    include InheritedPolicies

    included do
      has_many :oval_policies, :through => :oval_facet, :class_name => 'ForemanOpenscap::OvalPolicy'
    end

    def inherited_oval_policies
      find_inherited_policies :oval_policies
    end
  end
end
