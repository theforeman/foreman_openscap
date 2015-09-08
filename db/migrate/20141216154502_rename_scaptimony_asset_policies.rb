class RenameScaptimonyAssetPolicies < ActiveRecord::Migration
  def change
    rename_table(:scaptimony_assets_policies, :scaptimony_asset_policies)
  end
end
