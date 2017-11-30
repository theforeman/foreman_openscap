class CreateScaptimonyXccdfResults < ActiveRecord::Migration[4.2]
  def change
    create_table :scaptimony_xccdf_results do |t|
      t.string :name, :limit => 16, :null => false
    end
    add_index :scaptimony_xccdf_results, [:name], :unique => true
  end
end
