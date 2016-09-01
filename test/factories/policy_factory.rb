FactoryGirl.define do
  factory :policy, :class => ::ForemanOpenscap::Policy do
    sequence(:name) { |n| "policy#{n}" }
    period 'weekly'
    weekday 'monday'
    scap_content
    scap_content_profile
    day_of_month nil
    cron_line nil
    hosts []
    assets []
  end
end
