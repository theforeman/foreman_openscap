class AddDescriptionToScaptimonyPolicyRevisions < ActiveRecord::Migration[4.2]
  def change
    add_column :scaptimony_policy_revisions, :description, :string
  end
end
