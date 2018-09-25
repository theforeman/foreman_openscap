FactoryBot.define do
  factory :arf_report, :class => ::ForemanOpenscap::ArfReport do
    host_id 1
    policy nil
    policy_arf_report nil
    sequence(:reported_at) { |n| Time.new(1490 + n, 0o1, 13, 15, 24, 0o0) }
    sequence(:created_at) { |n| Time.new(1490 + n, 0o1, 13, 15, 24, 0o0) }
    status 0
    metrics({})
    openscap_proxy nil
  end
end
