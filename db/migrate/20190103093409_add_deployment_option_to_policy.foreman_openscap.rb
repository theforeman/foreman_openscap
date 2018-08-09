class AddDeploymentOptionToPolicy < ActiveRecord::Migration[5.2]
  def up
    add_column :foreman_openscap_policies, :deploy_by, :string
    ForemanOpenscap::Policy.unscoped.in_batches do |batch|
      batch.map do |policy|
        policy.update_attribute(:deploy_by, 'puppet')
      end
    end
    change_column :foreman_openscap_policies, :deploy_by, :string, :null => false
  end

  def down
    remove_column :foreman_openscap_policies, :deploy_by
  end
end
