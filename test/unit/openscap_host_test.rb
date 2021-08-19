require 'test_plugin_helper'

class OpenscapHostTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
    User.current = users :admin
    @policy = FactoryBot.create(:policy)
  end

  test 'Host has policy' do
    host = FactoryBot.create(:host)
    assert_empty(host.policies)
    @policy.host_ids = [host.id]
    @policy.save
    assert_includes(host.policies, @policy)
  end

  test 'Host has policies via its hostgroup' do
    host = FactoryBot.create(:host, :with_hostgroup)
    hostgroup = host.hostgroup
    @policy.hostgroup_ids = [hostgroup.id]
    assert @policy.save
    refute_empty(host.combined_policies)
    assert_includes(host.combined_policies, @policy)
  end

  test 'Host has policies via its host group and its parent host groups' do
    host = FactoryBot.create(:host, :with_hostgroup)
    hostgroup = host.hostgroup
    hostgroup.parent = FactoryBot.create(:hostgroup)
    @policy.hostgroup_ids = [hostgroup.parent.id]
    assert @policy.save
    refute_empty(host.combined_policies)
    assert_includes(host.combined_policies, @policy)
  end

  context 'testing scap_status_changed?' do
    setup do
      @host = FactoryBot.create(:compliance_host)
      @report_1 = FactoryBot.create(:arf_report, :policy => @policy, :host_id => @host.id)
      @report_2 = FactoryBot.create(:arf_report, :policy => @policy, :host_id => @host.id)
      @policy_report_1 = FactoryBot.create(:policy_arf_report, :policy_id => @policy.id, :arf_report_id => @report_1.id)
      @policy_report_2 = FactoryBot.create(:policy_arf_report, :policy_id => @policy.id, :arf_report_id => @report_2.id)
    end

    test "reports for policy should return expected reports" do
      @report_2.reported_at += 10.minutes
      @report_2.save!
      reports = @host.reports_for_policy(@policy)
      assert_equal 2, reports.count
      assert reports.include?(@report_1)
      assert reports.include?(@report_2)
      # Ensure the last report list first
      assert_equal @report_2, reports.first
    end

    test "last report for policy should return the latest report only" do
      @report_2.reported_at += 10.minutes
      @report_2.save!
      reports = @host.last_report_for_policy(@policy)
      assert_equal 1, reports.count
      assert_equal @report_2, reports.first
    end

    test 'scap_status_changed should detect status change' do
      ForemanOpenscap::ArfReport.any_instance.stubs(:equal?).returns(false)
      assert @host.scap_status_changed?(@policy)
    end

    test 'scap_status_changed should not detect status change when there is none' do
      ForemanOpenscap::ArfReport.any_instance.stubs(:equal?).returns(true)
      refute @host.scap_status_changed?(@policy)
    end

    test 'scap_status_changed should not detect status change when there are reports < 2' do
      openscap_proxy_api = ::ProxyAPI::Openscap.new(:url => 'https://test-proxy.com:9090')
      openscap_proxy_api.stubs(:destroy_report).returns(true)
      ForemanOpenscap::Helper.stubs(:find_name_or_uuid_by_host).returns("abcde")
      ForemanOpenscap::ArfReport.any_instance.stubs(:openscap_proxy_api).returns(openscap_proxy_api)
      @report_2.destroy
      refute @host.scap_status_changed?(@policy)
    end
  end
end
