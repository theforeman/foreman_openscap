class RemoveXccdfProfileFromScaptimonyPolicies < ActiveRecord::Migration
  def change
    remove_column :scaptimony_policies, :xccdf_profile
  end
end
