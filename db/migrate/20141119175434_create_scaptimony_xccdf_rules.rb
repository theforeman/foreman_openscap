class CreateScaptimonyXccdfRules < ActiveRecord::Migration
  def change
    create_table :scaptimony_xccdf_rules do |t|
      t.string :xid, :null => false
    end
    add_index :scaptimony_xccdf_rules, [:xid], :unique => true
  end
end
