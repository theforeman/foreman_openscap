module ForemanOpenscap
  module Hostgroup
    class OvalFacet < ApplicationRecord
      self.table_name = 'foreman_openscap_hostgroup_oval_facets'

      include Facets::HostgroupFacet

      validates :hostgroup, :presence => true, :allow_blank => false

      has_many :hostgroup_oval_facet_oval_policies, :dependent => :destroy, :class_name => 'ForemanOpenscap::HostgroupOvalFacetOvalPolicy'
      has_many :oval_policies, :through => :hostgroup_oval_facet_oval_policies, :class_name => 'ForemanOpenscap::OvalPolicy'
    end
  end
end
