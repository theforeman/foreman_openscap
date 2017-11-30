class CreateScaptimonyAssets < ActiveRecord::Migration[4.2]
  def change
    create_table :scaptimony_assets do |t|
      t.string :name, :limit => 255

      t.timestamps
    end
    add_index :scaptimony_assets, :name, :unique => true
  end
end
