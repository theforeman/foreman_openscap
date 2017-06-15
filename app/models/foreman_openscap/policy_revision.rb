module ForemanOpenscap
  class PolicyRevision < ApplicationRecord
    belongs_to :policy
    belongs_to :scap_content
  end
end
