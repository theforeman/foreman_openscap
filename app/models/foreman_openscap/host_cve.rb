module ForemanOpenscap
  class HostCve < ApplicationRecord
    belongs_to_host
    belongs_to :cve
    belongs_to :oval_policy
  end
end
