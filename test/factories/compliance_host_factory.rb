FactoryGirl.define do
  factory :openscap_feature, :class => Feature do
    name 'Openscap'
  end

  factory :openscap_proxy, :class => SmartProxy do
    sequence(:name) { |n| "proxy#{n}" }
    sequence(:url) { |n| "https://somewhere#{n}.net:8443" }
    features { |sp| [sp.association(:openscap_feature)] }
  end

  factory :compliance_host, :class => Host::Managed do
    sequence(:name) { |n| "host#{n}" }
    sequence(:hostname) { |n| "hostname#{n}" }
    root_pass 'xybxa6JUkz63w'
    openscap_proxy { SmartProxy.unscoped.with_features('Openscap').first || FactoryGirl.create(:openscap_proxy) }
    policies []
  end
end
