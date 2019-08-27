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

  def compliance_host_multiple_actions
    [
      { :action => [_('Assign Compliance Policy'), select_multiple_hosts_policies_path], :priority => 1210 },
      { :action => [_('Unassign Compliance Policy'), disassociate_multiple_hosts_policies_path], :priority => 1211 },
      { :action => [_('Change OpenSCAP Proxy'), select_multiple_openscap_proxy_hosts_path], :priority => 1212 },
    ]
  end

  def compliance_host_overview_button(host)
    return [] if host.arf_reports.none?
    [
      {
        :button => link_to_if_authorized(
          _('Compliance'),
          hash_for_compliance_host_path(host.id),
          :title => _("Host compliance details"),
          :class => 'btn btn-default'
        ),
        :priority => 1000
      }
    ]
  end
end
