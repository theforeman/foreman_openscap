require 'test_plugin_helper'

class PolicyDashboardHelperTest < ActionView::TestCase
  include ArfReportDashboardHelper
  include PolicyDashboardHelper

  test 'should return data for policy breakdown chart' do
    report = {
      :compliant_hosts => 5,
      :incompliant_hosts => 6,
      :inconclusive_hosts => 7,
      :report_missing => 8
    }
    res = JSON.parse(policy_breakdown_chart_data(report))
    assert_equal 4, res.size
    assert_include res, ['Compliant hosts', 5, PolicyDashboardHelper::COLORS[:compliant_hosts]]
    assert_include res, ['Incompliant hosts', 6, PolicyDashboardHelper::COLORS[:incompliant_hosts]]
    assert_include res, ['Inconclusive', 7, PolicyDashboardHelper::COLORS[:inconclusive_hosts]]
    assert_include res, ['Not audited', 8, PolicyDashboardHelper::COLORS[:report_missing]]
  end
end
