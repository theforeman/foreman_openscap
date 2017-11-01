FactoryBot.define do
  factory :policy, :class => ::ForemanOpenscap::Policy do
    sequence(:name) { |n| "policy#{n}" }
    period 'weekly'
    weekday 'monday'
    scap_content { FactoryBot.create(:scap_content) }
    scap_content_profile { FactoryBot.create(:scap_content_profile, :scap_content => scap_content) }
    tailoring_file nil
    tailoring_file_profile nil
    day_of_month nil
    cron_line nil
    hosts []
    assets []
  end
end
