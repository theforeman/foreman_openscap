class CreateScaptimonyAssetsPolicies < ActiveRecord::Migration[4.2]
  def change
    create_table :scaptimony_assets_policies, :id => false do |t|
      t.references :asset, :index => true, :null => false
      t.references :policy, :index => true, :null => false
    end
    add_index :scaptimony_assets_policies, %i[asset_id policy_id], :unique => true
  end
end
