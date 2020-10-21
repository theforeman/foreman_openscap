module ForemanOpenscap
  class HostgroupOvalFacetOvalPolicy < ApplicationRecord
    belongs_to :oval_policy
    belongs_to :oval_facet, :class_name => 'ForemanOpenscap::Hostgroup::OvalFacet'
  end
end
