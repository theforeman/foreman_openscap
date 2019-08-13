module ComplianceHostsHelper
  def host_arf_reports_chart(policy_id)
    passed = []
    failed = []
    othered = []
    @host.arf_reports.of_policy(policy_id).each do |report|
      passed  << [report.created_at.to_i * 1000, report.passed]
      failed  << [report.created_at.to_i * 1000, report.failed]
      othered << [report.created_at.to_i * 1000, report.othered]
    end
    [{ :label => _("Passed"), :data => passed, :color => ArfReportDashboardHelper::COLORS[:passed] },
     { :label => _("Failed"), :data => failed, :color => ArfReportDashboardHelper::COLORS[:failed] },
     { :label => _("Othered"), :data => othered, :color => ArfReportDashboardHelper::COLORS[:othered] }]
  end
end
