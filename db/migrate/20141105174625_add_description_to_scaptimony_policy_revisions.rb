class AddDescriptionToScaptimonyPolicyRevisions < ActiveRecord::Migration
  def change
    add_column :scaptimony_policy_revisions, :description, :string
  end
end
