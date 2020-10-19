FactoryBot.define do
  factory :oval_policy, :class => ::ForemanOpenscap::OvalPolicy do
    sequence(:name) { |n| "policy#{n}" }
    period { 'weekly' }
    weekday { 'monday' }
    day_of_month { nil }
    cron_line { nil }
  end
end
