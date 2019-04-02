require 'test_plugin_helper'

class HostExtensionsTest < ActiveSupport::TestCase
  setup do
    ForemanOpenscap::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
    @scap_content = FactoryBot.create(:scap_content)
    @scap_content_profile = FactoryBot.create(:scap_content_profile, :scap_content => @scap_content)
    @policy = FactoryBot.create(:policy, :scap_content => @scap_content, :scap_content_profile => @scap_content_profile)
    @host = FactoryBot.create(:compliance_host, :policies => [@policy])
  end

  test "should have download_path in enc without digest" do
    ForemanOpenscap::OpenscapProxyAssignedVersionCheck.any_instance.stubs(:openscap_proxy_versions)
                                                      .returns('test-proxy' => '0.5.4')
    enc_out = JSON.parse @host.policies_enc
    assert_equal 5, enc_out.first['download_path'].split('/').length
  end

  test "should have download_path in enc with digest" do
    ForemanOpenscap::OpenscapProxyAssignedVersionCheck.any_instance.stubs(:openscap_proxy_versions)
                                                      .returns({})
    enc_out = JSON.parse @host.policies_enc
    assert_equal 6, enc_out.first['download_path'].split('/').length
  end

  test "should find hosts with direct policy assignment that were never audited" do
    policy, host, host_2 = setup_hosts_with_policy.values_at(:policy, :host, :host_2)
    report = FactoryBot.create(:arf_report, :host_id => host_2.id)
    FactoryBot.create(:policy_arf_report, :policy_id => policy.id, :arf_report_id => report.id)

    res = Host.policy_reports_missing policy
    assert_equal res.count, 1
    assert_include res, host
  end

  test "should find hosts with inherited policy that were never audited" do
    policy, host, host_2 = setup_hosts_with_inherited_policy.values_at(:policy, :host, :host_2)
    report = FactoryBot.create(:arf_report, :host_id => host_2.id)
    FactoryBot.create(:policy_arf_report, :policy_id => policy.id, :arf_report_id => report.id)

    res = Host.policy_reports_missing policy
    assert_equal res.count, 1
    assert_include res, host
  end

  test "should find hosts that are assigned to policy directly" do
    policy, host, host_2 = setup_hosts_with_policy.values_at(:policy, :host, :host_2)
    res = Host.assigned_to_policy(policy)
    assert_equal 2, res.count
    assert_include res, host
    assert_include res, host_2
  end

  test "should find hosts with policy inherited from hostgroup" do
    policy, host, host_2 = setup_hosts_with_inherited_policy.values_at(:policy, :host, :host_2)
    res = Host.assigned_to_policy(policy)
    assert_equal 2, res.count
    assert_include res, host
    assert_include res, host_2
  end

  test "should find hosts with directly assigned policy when searching by policy id" do
    policy, host, host_2 = setup_hosts_with_policy.values_at(:policy, :host, :host_2)
    res = Host.search_for "compliance_policy_id = #{policy.id}"
    assert_equal 2, res.count
    assert_include res, host
    assert_include res, host_2
  end

  test "should find hosts with inherited policy when searching by policy id" do
    policy, host, host_2 = setup_hosts_with_inherited_policy.values_at(:policy, :host, :host_2)
    res = Host.search_for "compliance_policy_id = #{policy.id}"
    assert_equal 2, res.count
    assert_include res, host
    assert_include res, host_2
  end

  test "should correctly find hosts based on rule result" do
    rule_name = 'xccdf_org.something'
    rule_names = [rule_name, 'xccdf_org.nothing']
    rule_results_1 = ['pass', 'fail']
    rule_results_2 = ['fail', 'fail']
    rule_results_3 = ['notchecked', 'fail']
    host_1 = setup_host_with_reports_and_rules([rule_names, rule_names], [rule_results_2, rule_results_1], @policy)
    host_2 = setup_host_with_reports_and_rules([rule_names, rule_names], [rule_results_1, rule_results_2], @policy)
    host_3 = setup_host_with_reports_and_rules([rule_names, rule_names], [rule_results_1, rule_results_3], @policy)

    res = Host.search_for "passes_xccdf_rule = #{rule_name}"
    assert_equal res.first, host_1

    res = Host.search_for "fails_xccdf_rule = #{rule_name}"
    assert_equal res.first, host_2

    res = Host.search_for "others_xccdf_rule = #{rule_name}"
    assert_equal res.first, host_3
  end

  context "find_with_any_policy" do
    setup do
      @host.destroy
      policy, host, host_2 = setup_hosts_with_inherited_policy.values_at(:policy, :host, :host_2)
      policy, host_3, host_4 = setup_hosts_with_policy.values_at(:policy, :host, :host_2)
      @compliance_hosts = [host, host_2, host_3, host_4]
      @host_without_policy = FactoryBot.create(:host)
    end

    test "should find compliance hosts" do
      res = Host.search_for "is_compliance_host = true"
      assert_equal 4, res.count
      assert_empty(@compliance_hosts - res | res - @compliance_hosts)
    end

    test "should find all but compliance hosts" do
      res = Host.search_for "is_compliance_host = false"
      assert_equal 1, res.count
      assert_equal @host_without_policy, res.first
    end
  end

  test 'should find hosts by compliance with policy using scoped search' do
    rule_names = ['xccdf_org.something', 'xccdf_org.nothing']
    rule_results_1 = ['pass', 'pass']
    rule_results_2 = ['fail', 'pass']
    rule_results_3 = ['notchecked', 'pass']
    host_1 = setup_host_with_reports_and_rules([rule_names, rule_names], [rule_results_2, rule_results_1], @policy)
    host_2 = setup_host_with_reports_and_rules([rule_names, rule_names], [rule_results_1, rule_results_2], @policy)
    host_3 = setup_host_with_reports_and_rules([rule_names, rule_names], [rule_results_1, rule_results_3], @policy)

    compliant = Host.search_for "comply_with = #{@policy.name}"
    assert_equal [host_1], compliant

    incompliant = Host.search_for "not_comply_with = #{@policy.name}"
    assert_equal [host_2], incompliant

    inconclusive = Host.search_for "inconclusive_with = #{@policy.name}"
    assert_equal [host_3], inconclusive
  end

  test "should find hosts removed from policy" do
    rule_names = ['xccdf_org.something', 'xccdf_org.nothing']
    rule_results = ['pass', 'pass']
    host_1 = setup_host_with_reports_and_rules([rule_names], [rule_results], @policy)
    host_2 = setup_host_with_reports_and_rules([rule_names], [rule_results], @policy)

    scap_content = FactoryBot.create(:scap_content)
    scap_content_profile = FactoryBot.create(:scap_content_profile, :scap_content => scap_content)
    different_policy = FactoryBot.create(:policy, :scap_content => scap_content, :scap_content_profile => scap_content_profile)

    report = FactoryBot.create(:arf_report, :host_id => host_2.id)
    FactoryBot.create(:policy_arf_report, :policy_id => different_policy.id, :arf_report_id => report.id)

    removed = Host.removed_from_policy different_policy
    not_removed = Host.removed_from_policy @policy

    assert_equal [host_2], removed
    assert_empty not_removed
  end

  private

  def setup_hosts_with_policy
    policy = FactoryBot.create(:policy)
    host = FactoryBot.create(:compliance_host)
    host_2 = FactoryBot.create(:compliance_host)
    asset = FactoryBot.create(:asset, :assetable_id => host.id, :assetable_type => 'Host::Base')
    asset_2 = FactoryBot.create(:asset, :assetable_id => host_2.id, :assetable_type => 'Host::Base')
    FactoryBot.create(:asset_policy, :asset_id => asset.id, :policy_id => policy.id)
    FactoryBot.create(:asset_policy, :asset_id => asset_2.id, :policy_id => policy.id)
    { :host => host, :policy => policy, :host_2 => host_2 }
  end

  def setup_hosts_with_inherited_policy
    policy = FactoryBot.create(:policy)
    parent = FactoryBot.create(:hostgroup)
    child = FactoryBot.create(:hostgroup, :ancestry => parent.id.to_s)
    asset = FactoryBot.create(:asset, :assetable_id => parent.id, :assetable_type => 'Hostgroup')
    FactoryBot.create(:asset_policy, :asset_id => asset.id, :policy_id => policy.id)
    host = FactoryBot.create(:compliance_host, :hostgroup_id => child.id)
    host_2 = FactoryBot.create(:compliance_host, :hostgroup_id => child.id)
    { :policy => policy, :host => host, :host_2 => host_2 }
  end

  def setup_host_with_reports_and_rules(rule_names_ary, rule_results_ary, policy)
    raise "rule_names_ary must have the same length as rule_results_ary" if rule_names_ary.size != rule_results_ary.size
    host = FactoryBot.create(:host)
    asset = FactoryBot.create(:asset, :assetable_id => host.id)
    FactoryBot.create(:asset_policy, :asset_id => asset.id, :policy_id => policy.id)
    rule_names_ary.each_with_index do |item, index|
      report = create_report_with_rules host, rule_names_ary[index], rule_results_ary[index]
      FactoryBot.create(:policy_arf_report, :policy_id => policy.id, :arf_report_id => report.id)
    end
    host
  end
end
