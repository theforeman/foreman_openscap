require 'test_plugin_helper'

class MessageCleanerTest < ActiveSupport::TestCase
  setup do
    ForemanOpenscap::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
  end

  test "should clean up messages" do
    host = FactoryGirl.create(:compliance_host)
    policy = FactoryGirl.create(:policy)
    reports = []
    source = FactoryGirl.create(:source, :value => "xccdf_org.ssgproject.content_rule_firefox_preferences-lock_settings_obscure")
    2.times do
      report = FactoryGirl.create(:arf_report, :host_id => host.id)
      message = FactoryGirl.create(:compliance_message, :value => "Disable Firefox Configuration File ROT-13 Encoding")
      FactoryGirl.create(:policy_arf_report, :policy_id => policy.id, :arf_report_id => report.id)
      FactoryGirl.create(:compliance_log, :source_id => source.id, :message_id => message.id, :report_id => report.id)
      report.reload
      reports << report
    end

    assert_equal 2, reports.flat_map(&:logs).map(&:message).uniq.count

    ForemanOpenscap::MessageCleaner.new.clean
    reports.map(&:reload)

    assert_equal 1, reports.flat_map(&:logs).map(&:message).uniq.count
    log_a, log_b = reports.flat_map(&:logs)
    assert_equal log_a.message, log_b.message
  end
end
