class RemoveXccdfProfileFromScaptimonyPolicies < ActiveRecord::Migration[4.2]
  def change
    remove_column :scaptimony_policies, :xccdf_profile, :string
  end
end
