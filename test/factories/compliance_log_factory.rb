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
    after(:build) do |msg|
      msg.digest = Digest::SHA1.hexdigest(msg.value)
    end
  end

  factory :compliance_source, :class => :source do
    sequence(:value) { |n| "source#{n}" }
    after(:build) do |source|
      source.digest = Digest::SHA1.hexdigest(source.value)
    end
  end
end
