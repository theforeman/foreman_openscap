module ForemanOpenscap
  class Cve < ApplicationRecord
    has_many :host_cves
    has_many :hosts, :through => :host_cves

    validates :ref_id, :ref_url, :definition_id, :presence => true

    class Jail < ::Safemode::Jail
      allow :ref_id, :ref_url
    end
  end
end
