class CreateScaptimonyPolicyRevisions < ActiveRecord::Migration
  def change
    create_table :scaptimony_policy_revisions do |t|
      t.references :policy, index: true
      t.references :scap_content, index: true
      t.string :xccdf_profile
      t.string :period
      t.string :weekday
      t.timestamp :active_until

      t.timestamps
    end
  end
end
