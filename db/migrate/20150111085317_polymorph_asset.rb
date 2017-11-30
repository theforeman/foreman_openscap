class PolymorphAsset < ActiveRecord::Migration[4.2]
  def change
    change_table(:scaptimony_assets) do |t|
      t.references :assetable, :polymorphic => true, :index => true
      t.remove :name
    end
  end
end
