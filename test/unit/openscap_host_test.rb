require 'test_plugin_helper'

class OpenscapHostTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
    User.current = users :admin
    ForemanOpenscap::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
    @policy = FactoryGirl.create(:policy)
  end

  test 'Host has policy' do
    host = FactoryGirl.create(:host)
    assert_empty(host.policies)

    assert(@policy.assign_hosts([host]), 'Host policies should be assigned')
    assert_includes(host.policies, @policy)
  end

  test 'Host has policies via its hostgroup' do
    host = FactoryGirl.create(:host, :with_hostgroup)
    hostgroup = host.hostgroup
    assert(@policy.hostgroup_ids = ["#{hostgroup.id}"])
    refute_empty(host.combined_policies)
    assert_includes(host.combined_policies, @policy)
  end

  context 'testing scap_status_changed?' do
    setup do
      @host = FactoryGirl.create(:compliance_host)
      @report_1 = FactoryGirl.create(:arf_report, :policy => @policy, :host_id => @host.id)
      @report_2 = FactoryGirl.create(:arf_report, :policy => @policy, :host_id => @host.id)
      @policy_report_1 = FactoryGirl.create(:policy_arf_report, :policy_id => @policy.id, :arf_report_id => @report_1.id)
      @policy_report_2 = FactoryGirl.create(:policy_arf_report, :policy_id => @policy.id, :arf_report_id => @report_2.id)
    end

    test "reports for policy should return expected reports" do
      reports = @host.reports_for_policy(@policy)
      assert_equal 2, reports.count
      assert reports.include?(@report_1)
      assert reports.include?(@report_2)
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
