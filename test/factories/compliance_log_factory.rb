FactoryBot.define do
  factory :compliance_log, :class => :log do
    result { "fail" }
    association :report
    level_id { 1 }
    association :source
    association :message
  end

  factory :compliance_message, :class => :message do
    sequence(:value) { |n| "message#{n}" }
  end

  factory :compliance_source, :class => :source do
    sequence(:value) { |n| "source#{n}" }
  end
end
