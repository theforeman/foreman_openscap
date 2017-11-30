class AddConstraintToScaptimonyPolicies < ActiveRecord::Migration[4.2]
  def change
    change_column :scaptimony_policies, :name, :string, :null => false
  end
end
