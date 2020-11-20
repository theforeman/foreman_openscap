module ForemanOpenscap
  class Cve < ApplicationRecord
    has_many :host_cves
    has_many :hosts, :through => :host_cves

    validates :ref_id, :ref_url, :presence => true, :uniqueness => true
  end
end
