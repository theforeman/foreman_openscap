module ForemanOpenscap
  module OvalFacetHostExtensions
    extend ActiveSupport::Concern

    ::Host::Managed::Jail.allow :oval_policies_enc, :oval_policies_enc_raw

    included do
      has_many :oval_policies, :through => :oval_facet, :class_name => 'ForemanOpenscap::OvalPolicy'
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
