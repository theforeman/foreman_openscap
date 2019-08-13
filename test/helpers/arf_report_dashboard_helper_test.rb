require 'test_plugin_helper'

class ArfReportDashboardHelperTest < ActionView::TestCase
  include ArfReportDashboardHelper

  test 'should return breakdown chart data with custom colors as json' do
    categories = { :passed => 'passed', :failed => 'failed' }
    report = { :passed => 23, :failed => 24 }
    colors = { :passed => '#FFF', :failed => '#000' }
    res = JSON.parse(breakdown_chart_data(categories, report, colors))
    assert_equal ["passed", 23, "#FFF"], res.first
    assert_equal ["failed", 24, "#000"], res.last
  end

  test 'should return breakdown chart data for donut as json' do
    report = { :passed => 4, :failed => 7, :othered => 5 }
    res = JSON.parse(donut_breakdown_chart_data(report))
    assert_equal 3, res.size
    assert_include res, ["Passed", 4, ArfReportDashboardHelper::COLORS[:passed]]
    assert_include res, ["Failed", 7, ArfReportDashboardHelper::COLORS[:failed]]
    assert_include res, ["Other", 5, ArfReportDashboardHelper::COLORS[:othered]]
  end

  test 'should return data for report status chart' do
    res = JSON.parse(arf_report_status_chart_data(:passed => 6, :failed => 7, :othered => 8))
    assert_equal "Number of Events", res['yAxisLabel']
    assert_equal "Rule Results", res['xAxisLabel']
    assert_equal 3, res['data'].size
    assert_include res['data'], ["passed", 6]
    assert_include res['data'], ["failed", 7]
    assert_include res['data'], ["othered", 8]
  end
end
