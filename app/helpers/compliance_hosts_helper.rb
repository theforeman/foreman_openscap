module ComplianceHostsHelper
  def host_arf_reports_chart_data(policy_id)
    passed = []
    failed = []
    othered = []
    date = []
    @host.arf_reports.of_policy(policy_id).each do |report|
      passed  << report.passed
      failed  << report.failed
      othered << report.othered
      date << report.created_at.to_i * 1000
    end
    data = [
      [_("Passed"), passed, ArfReportDashboardHelper::COLORS[:passed]],
      [_("Failed"), failed, ArfReportDashboardHelper::COLORS[:failed]],
      [_("Othered"), othered, ArfReportDashboardHelper::COLORS[:othered]],
      ['dates', date, nil]
    ]
    { :data => data, :xAxisDataLabel => 'dates', :config => 'timeseries' }.to_json
  end
end
