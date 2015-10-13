FactoryGirl.define do
  factory :compliance_host, :class => Host::Managed do
    sequence(:name) { |n| "host#{n}" }
    sequence(:hostname) { |n| "host#{n}" }
    root_pass 'xybxa6JUkz63w'
    policies []
  end
end
