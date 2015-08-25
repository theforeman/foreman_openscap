class AddConstraintToScaptimonyPolicies < ActiveRecord::Migration
  def change
    change_column :scaptimony_policies, :name, :string, :null => false
  end
end
