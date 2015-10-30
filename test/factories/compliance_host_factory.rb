FactoryGirl.define do
  factory :compliance_host, :class => Host::Managed do
    sequence(:name) { |n| "host#{n}" }
    sequence(:hostname) { |n| "hostname#{n}" }
    root_pass 'xybxa6JUkz63w'
    policies []
    asset nil
  end
end
