module ForemanOpenscap
  class PolicyArfReport < ::ActiveRecord::Base
    belongs_to :arf_report
    belongs_to :policy

    scope :of_policy, lambda { |policy_id| joins(:policy).where(:policy_id => policy_id) }
  end
end
