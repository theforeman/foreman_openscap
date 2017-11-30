class RenameScaptimonyAssetPolicies < ActiveRecord::Migration[4.2]
  def change
    rename_table(:scaptimony_assets_policies, :scaptimony_asset_policies)
  end
end
