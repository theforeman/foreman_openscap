FactoryBot.define do
  factory :policy_arf_report, :class => ForemanOpenscap::PolicyArfReport do
    policy_id { nil }
    arf_report_id { nil }
  end
end
