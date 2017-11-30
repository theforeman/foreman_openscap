class CreateScaptimonyPolicies < ActiveRecord::Migration[4.2]
  def change
    create_table :scaptimony_policies do |t|
      t.string :name, :limit => 80

      t.timestamps
    end
  end
end
