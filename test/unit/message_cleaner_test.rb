require 'test_plugin_helper'
require 'foreman_openscap/message_cleaner'

class MessageCleanerTest < ActiveSupport::TestCase
  setup do
    ForemanOpenscap::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
  end

  test "should clean up messages" do
    host = FactoryBot.create(:compliance_host)
    policy = FactoryBot.create(:policy)
    reports = []
    source = FactoryBot.create(:source, :value => "xccdf_org.ssgproject.content_rule_firefox_preferences-lock_settings_obscure")
    2.times do
      report = FactoryBot.create(:arf_report, :host_id => host.id)
      message = FactoryBot.create(:compliance_message, :value => "Disable Firefox Configuration File ROT-13 Encoding")
      FactoryBot.create(:policy_arf_report, :policy_id => policy.id, :arf_report_id => report.id)
      FactoryBot.create(:compliance_log, :source_id => source.id, :message_id => message.id, :report_id => report.id)
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
