FactoryGirl.define do
  factory :arf_report, :class => ::ForemanOpenscap::ArfReport do
    host_id 1
    policy nil
    policy_arf_report nil
    sequence(:reported_at) { |n| Time.new(1490 + n, 01, 13, 15, 24, 00)}
    logs []
    status 0
    metrics {}
  end
end
