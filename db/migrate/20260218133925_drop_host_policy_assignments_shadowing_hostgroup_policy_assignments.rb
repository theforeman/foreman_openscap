class DropHostPolicyAssignmentsShadowingHostgroupPolicyAssignments < ActiveRecord::Migration[7.0]
  def up
    ForemanOpenscap::Asset.where(assetable_type: 'Hostgroup').joins(:asset_policies).find_each do |hg_asset|
      hostgroup = hg_asset.hostgroup
      next if hostgroup.nil?

      # Take all policies assigned to the hostgroup
      policy_ids = hg_asset.asset_policies.pluck(:policy_id)

      # Take ids of the hostgroup and all its children, all of these provide the policies extracted above
      hostgroup_ids = hostgroup.subtree_ids

      # Find hosts which are assigned to the hostgroup or its descendants, the hostgroup provides its policies to all of those
      host_subselect = Host.where(hostgroup_id: hostgroup_ids)

      # Take all the hosts which have direct association with a policy that is already provided by their hostgroup
      scope = ForemanOpenscap::AssetPolicy.joins(:asset).joins(:policy)
                .where(asset: { assetable_type: 'Host::Base', assetable_id: host_subselect })
                .where(policy_id: policy_ids)
      
      scope.each do |asset_policy|
        # Composite primary keys are supported in rails >=7.1, since we're on 7.0, raw SQL will have to do
        ActiveRecord::Base.connection.execute("DELETE FROM foreman_openscap_asset_policies WHERE asset_id = #{asset_policy.asset_id} AND policy_id = #{asset_policy.policy_id}")
      end
    end

    # Prune host assets which do not have any policies assigned to them
    scope = ForemanOpenscap::Asset.where(assetable_type: 'Host::Base').left_outer_joins(:asset_policies)
    scope = scope.where('foreman_openscap_asset_policies.asset_id IS NULL')
    # ForemanOpenscap::Asset has :dependent => :delete_all callback on asset_policies, but since we're pruning assets which don't have any asset_policies, we don't need the callback
    scope.delete_all
  end

  def down
  end
end
