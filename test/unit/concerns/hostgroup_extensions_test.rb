require 'test_plugin_helper'

class HostgroupExtensionsTest < ActiveSupport::TestCase
  test "should remove all linked assets on hostgroup destroy" do
    hostgroup = FactoryBot.create(:hostgroup)
    FactoryBot.create_list(:asset, 3, :assetable_id => hostgroup.id, :assetable_type => 'Hostgroup')
    asset_scope = ::ForemanOpenscap::Asset.where(:assetable_id => hostgroup.id, :assetable_type => 'Hostgroup')
    assert_difference("asset_scope.count", -3) { hostgroup.destroy }
  end

  test "should reset compliance status for subtree when assigning policy through hostgroup asset policies" do
    parent = FactoryBot.create(:hostgroup)
    child = FactoryBot.create(:hostgroup, :ancestry => parent.id.to_s)
    parent_host = FactoryBot.create(:compliance_host, :hostgroup_id => parent.id)
    child_host = FactoryBot.create(:compliance_host, :hostgroup_id => child.id)
    policy = FactoryBot.create(:policy)
    asset = FactoryBot.create(:asset, :assetable_id => parent.id, :assetable_type => 'Hostgroup')

    set_compliance_status(parent_host, ForemanOpenscap::ComplianceStatus::COMPLIANT)
    set_compliance_status(child_host, ForemanOpenscap::ComplianceStatus::COMPLIANT)

    asset.policies = [policy]

    assert_equal ForemanOpenscap::ComplianceStatus::INCONCLUSIVE, parent_host.reload.compliance_status
    assert_equal ForemanOpenscap::ComplianceStatus::INCONCLUSIVE, child_host.reload.compliance_status
  end

  test "should reset compliance status for subtree when removing policy through hostgroup asset policies" do
    parent = FactoryBot.create(:hostgroup)
    child = FactoryBot.create(:hostgroup, :ancestry => parent.id.to_s)
    parent_host = FactoryBot.create(:compliance_host, :hostgroup_id => parent.id)
    child_host = FactoryBot.create(:compliance_host, :hostgroup_id => child.id)
    policy = FactoryBot.create(:policy)
    asset = FactoryBot.create(:asset, :assetable_id => parent.id, :assetable_type => 'Hostgroup')
    asset.policies = [policy]

    set_compliance_status(parent_host, ForemanOpenscap::ComplianceStatus::COMPLIANT)
    set_compliance_status(child_host, ForemanOpenscap::ComplianceStatus::COMPLIANT)

    asset.policies = []

    assert_equal ForemanOpenscap::ComplianceStatus::INCONCLUSIVE, parent_host.reload.compliance_status
    assert_equal ForemanOpenscap::ComplianceStatus::INCONCLUSIVE, child_host.reload.compliance_status
  end

  test "should reset compliance status for subtree when hostgroup is reparented" do
    old_parent = FactoryBot.create(:hostgroup)
    new_parent = FactoryBot.create(:hostgroup)
    moved = FactoryBot.create(:hostgroup, :ancestry => old_parent.id.to_s)
    child = FactoryBot.create(:hostgroup, :ancestry => "#{old_parent.id}/#{moved.id}")
    moved_host = FactoryBot.create(:compliance_host, :hostgroup_id => moved.id)
    child_host = FactoryBot.create(:compliance_host, :hostgroup_id => child.id)
    unrelated_host = FactoryBot.create(:compliance_host, :hostgroup_id => old_parent.id)
    [moved_host, child_host, unrelated_host].each do |host|
      set_compliance_status(host, ForemanOpenscap::ComplianceStatus::COMPLIANT)
    end

    moved.update!(:parent_id => new_parent.id)

    assert_equal ForemanOpenscap::ComplianceStatus::INCONCLUSIVE, moved_host.reload.compliance_status
    assert_equal ForemanOpenscap::ComplianceStatus::INCONCLUSIVE, child_host.reload.compliance_status
    assert_equal ForemanOpenscap::ComplianceStatus::COMPLIANT, unrelated_host.reload.compliance_status
  end

  test "should not reset compliance status for hostgroup save without ancestry change" do
    hostgroup = FactoryBot.create(:hostgroup)
    host = FactoryBot.create(:compliance_host, :hostgroup_id => hostgroup.id)
    set_compliance_status(host, ForemanOpenscap::ComplianceStatus::COMPLIANT)

    hostgroup.update!(:name => 'renamed')

    assert_equal ForemanOpenscap::ComplianceStatus::COMPLIANT, host.reload.compliance_status
  end
end
