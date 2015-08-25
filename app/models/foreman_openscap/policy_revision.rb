module ForemanOpenscap
  class PolicyRevision < ActiveRecord::Base
    belongs_to :policy
    belongs_to :scap_content
  end
end
