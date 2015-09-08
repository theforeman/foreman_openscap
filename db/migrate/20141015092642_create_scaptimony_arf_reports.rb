class CreateScaptimonyArfReports < ActiveRecord::Migration
  def change
    create_table :scaptimony_arf_reports do |t|
      t.references :asset, index: true
      t.references :policy, index: true
      t.datetime :date
      t.string :digest, limit: 128

      t.timestamps
    end
    add_index :scaptimony_arf_reports, :digest, unique: true
  end
end
