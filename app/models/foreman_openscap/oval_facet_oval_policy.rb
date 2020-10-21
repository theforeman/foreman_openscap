module ForemanOpenscap
  class OvalFacetOvalPolicy < ApplicationRecord
    belongs_to :oval_policy
    belongs_to :oval_facet, :class_name => 'ForemanOpenscap::Host::OvalFacet'
  end
end
