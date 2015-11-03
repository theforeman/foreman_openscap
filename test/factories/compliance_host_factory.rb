FactoryGirl.define do
  factory :compliance_host, :class => Host::Managed do
    sequence(:name) { |n| "host#{n}" }
    sequence(:hostname) { |n| "hostname#{n}" }
    root_pass 'xybxa6JUkz63w'
    openscap_proxy FactoryGirl.build(:smart_proxy, :url => "http://test.org:8080")
    policies []
  end
end
