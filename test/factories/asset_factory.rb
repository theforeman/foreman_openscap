FactoryBot.define do
  factory :asset, :class => ::ForemanOpenscap::Asset do |f|
    f.assetable_id { FactoryBot.create(:host).id }
    f.assetable_type { 'Host::Base' }
  end

  factory :asset_policy, :class => ForemanOpenscap::AssetPolicy do |f|
    f.asset_id { nil }
    f.policy_id { nil }
  end
end
