module ForemanOpenscap
  module Host
    class OvalFacet < ApplicationRecord
      self.table_name = 'foreman_openscap_oval_facets'

      include Facets::Base

      validates :host, :presence => true, :allow_blank => false

      has_many :oval_facet_oval_policies, :dependent => :destroy, :class_name => 'ForemanOpenscap::OvalFacetOvalPolicy'
      has_many :oval_policies, :through => :oval_facet_oval_policies, :class_name =>'ForemanOpenscap::OvalPolicy'
    end
  end
end