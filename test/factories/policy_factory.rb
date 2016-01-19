FactoryGirl.define do
  factory :policy, :class => ::ForemanOpenscap::Policy do
    sequence(:name) { |n| "policy#{n}" }
    period 'weekly'
    weekday 'monday'
    scap_content
    scap_content_profile
    day_of_month '1'
    cron_line '* * * * 30'
    hosts []
    assets []
  end
end
