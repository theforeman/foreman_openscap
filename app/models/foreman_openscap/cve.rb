module ForemanOpenscap
  class Cve < ApplicationRecord
    has_many :host_cves
    has_many :hosts, :through => :host_cves
    has_many :oval_policies, :through => :host_cves

    scoped_search :relation => :host_cves, :on => :oval_policy_id, :rename => :oval_policy_id, :complete_value => false, :only_explicit => true
    scoped_search :relation => :host_cves, :on => :host_id, :rename => :host_id, :complete_value => false, :only_explicit => true

    scope :of_oval_policy, ->(policy_id) {
      joins(:host_cves).where(:foreman_openscap_host_cves => { :oval_policy_id => policy_id })
    }

    scope :of_host, ->(host_id) {
      joins(:host_cves).where(:foreman_openscap_host_cves => { :host_id => host_id })
    }

    validates :ref_id, :ref_url, :definition_id, :presence => true

    class Jail < ::Safemode::Jail
      allow :ref_id, :ref_url
    end
  end
end
