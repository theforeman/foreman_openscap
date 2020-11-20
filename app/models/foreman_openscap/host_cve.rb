module ForemanOpenscap
  class HostCve < ApplicationRecord
    belongs_to_host
    belongs_to :cve
  end
end
