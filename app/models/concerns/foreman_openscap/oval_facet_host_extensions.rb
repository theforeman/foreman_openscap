module ForemanOpenscap
  module OvalFacetHostExtensions
    extend ActiveSupport::Concern

    ::Host::Managed::Jail.allow :oval_policies_enc, :oval_policies_enc_raw, :cves, :cves_without_errata

    included do
      has_many :oval_policies, :through => :oval_facet, :class_name => 'ForemanOpenscap::OvalPolicy'

      has_many :host_cves, :class_name => 'ForemanOpenscap::HostCve', :foreign_key => :host_id
      has_many :cves, :through => :host_cves, :class_name => 'ForemanOpenscap::Cve', :source => :cve

      scoped_search :relation => :host_cves, :on => :cve_id, :rename => :cve_id, :complete_value => false
    end

    def cves_without_errata
      cves.where(:has_errata => false)
    end

    def cves_with_errata
      cves.where(:has_errata => true)
    end

    def combined_oval_policies
      combined = oval_policies
      combined += hostgroup.oval_policies + hostgroup.inherited_oval_policies if hostgroup
      combined.uniq
    end

    def oval_policies_enc_raw
      combined_oval_policies.map(&:to_enc)
    end

    def oval_policies_enc
      oval_policies_enc_raw.to_json
    end
  end
end
