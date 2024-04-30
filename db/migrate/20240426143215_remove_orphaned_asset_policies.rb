class RemoveOrphanedAssetPolicies < ActiveRecord::Migration[6.0]
  def up
    orphaned_asset_policy_ids = ForemanOpenscap::AssetPolicy.left_outer_joins(:asset).where(asset: { id: nil }).pluck(:asset_id)
    ForemanOpenscap::AssetPolicy.where(asset_id: orphaned_asset_policy_ids).delete_all
  end
end
