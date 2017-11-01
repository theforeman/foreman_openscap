require 'test_plugin_helper'

class DataTest < ActiveSupport::TestCase
  setup do
    @host = FactoryBot.create(:compliance_host)
    @arf = FactoryBot.create(:arf_report, :host_id => @host.id)
    @source = FactoryBot.create(:source)
    @failed = []
    @passed = []
    3.times do
      @failed << FactoryBot.create(:compliance_log, :report_id => @arf.id, :source => @source)
    end
    2.times do
      @passed << FactoryBot.create(:compliance_log, :report_id => @arf.id, :result => "pass", :source => @source)
    end
    @othered = [FactoryBot.create(:compliance_log, :report_id => @arf.id, :result => "unknown", :source => @source)]
  end

  test 'should fetch data' do
    report_data = ForemanOpenscap::ReportDashboard::Data.new.report
    assert_equal 3, report_data[:failed]
    assert_equal 2, report_data[:passed]
    assert_equal 1, report_data[:othered]
  end
end
