FactoryGirl.define do
  factory :asset, :class => Scaptimony::Asset do |f|
    f.assetable_id Host.first.id ##@TODO: find out why FactoryGirl.create(:host) fails on name validation
    f.assetable_type 'Host::Base'
  end
end