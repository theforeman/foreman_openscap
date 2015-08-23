require 'test_plugin_helper'

class OpenscapHostTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
    User.current = users :admin
    Scaptimony::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
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
      @host = FactoryGirl.create(:host)
      @report_1 = FactoryGirl.create(:arf_report, :policy => @policy, :host => @host)
      @report_2 = FactoryGirl.create(:arf_report, :policy => @policy, :host => @host)
    end

    test 'scap_status_changed should detect status change' do
      Scaptimony::ArfReport.any_instance.stubs(:equal?).returns(false)
      refute(@host.scap_status_changed?(@policy))
    end

    test 'scap_status_changed should not detect status change when there is none' do
      Scaptimony::ArfReport.any_instance.stubs(:equal?).returns(true)
      refute(@host.scap_status_changed?(@policy))
    end

    test 'scap_status_changed should not detect status change when there are reports < 2' do
      @report_2.destroy
      refute(@host.scap_status_changed?(@policy))
    end
  end
end
