FactoryGirl.define do
  factory :asset, :class => ::ForemanOpenscap::Asset do |f|
    f.assetable_id { FactoryGirl.create(:host).id }
    f.assetable_type 'Host::Base'
  end
end
