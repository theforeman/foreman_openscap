require 'test_plugin_helper'

class ComplianceStatusTest < ActiveSupport::TestCase
  def setup
    disable_orchestration
    User.current = users :admin
    ForemanOpenscap::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
    @policy_a = FactoryGirl.create(:policy)
    @policy_b = FactoryGirl.create(:policy)
    @failed_report = FactoryGirl.create(:arf_report)
    @failed_report.stubs(:failed?).returns(true)
    @passed_report = FactoryGirl.create(:arf_report)
    @passed_report.stubs(:failed?).returns(false)
    @passed_report.stubs(:othered?).returns(false)
    @othered_report = FactoryGirl.create(:arf_report)
    @othered_report.stubs(:failed?).returns(false)
    @othered_report.stubs(:othered?).returns(true)
  end

  test 'status should be incompliant' do
    status = ForemanOpenscap::ComplianceStatus.new
    host = FactoryGirl.create(:compliance_host, :policies => [@policy_a, @policy_b])
    host.stubs(:last_report_for_policy).returns(@failed_report, @passed_report)
    status.host = host
    assert_equal 2, status.to_status
  end

  test 'status should be inconclusive' do
    status = ForemanOpenscap::ComplianceStatus.new
    host = FactoryGirl.create(:compliance_host, :policies => [@policy_a, @policy_b])
    host.stubs(:last_report_for_policy).returns(@othered_report, @passed_report)
    status.host = host
    assert_equal 1, status.to_status
  end

  test 'status should be compliant' do
    status = ForemanOpenscap::ComplianceStatus.new
    host = FactoryGirl.create(:compliance_host, :policies => [@policy_a, @policy_b])
    passed_report = FactoryGirl.create(:arf_report)
    passed_report.stubs(:failed?).returns(false)
    passed_report.stubs(:othered?).returns(false)
    host.stubs(:last_report_for_policy).returns(passed_report, @passed_report)
    status.host = host
    assert_equal 0, status.to_status
  end

end
