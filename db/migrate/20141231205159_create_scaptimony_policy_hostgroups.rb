class CreateScaptimonyPolicyHostgroups < ActiveRecord::Migration
  def change
    create_table :scaptimony_policy_hostgroups do |t|
      t.integer :policy_id
      t.integer :hostgroup_id

      t.timestamps
    end
  end
end
