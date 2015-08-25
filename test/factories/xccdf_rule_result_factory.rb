FactoryGirl.define do
  factory :xccdf_rule_result, :class => ForemanOpenscap::XccdfRuleResult do
    xccdf_result_id 1
    xccdf_rule_id 1
  end
end