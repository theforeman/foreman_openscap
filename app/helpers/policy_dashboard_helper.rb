module PolicyDashboardHelper
  COLORS = {
    :compliant_hosts => ArfReportDashboardHelper::COLORS[:passed],
    :incompliant_hosts => ArfReportDashboardHelper::COLORS[:failed],
    :inconclusive_hosts => ArfReportDashboardHelper::COLORS[:othered],
    :report_missing => '#92A8CD',
  }.freeze

  def policy_breakdown_chart_data(report)
    categories = {
      :compliant_hosts =>  _('Compliant hosts'),
      :incompliant_hosts =>  _('Incompliant hosts'),
      :inconclusive_hosts => _('Inconclusive'),
      :report_missing =>  _('Not audited'),
    }

    breakdown_chart_data categories, report, COLORS
  end

  def status_link(name, label, path)
    content_tag :li do
      content_tag(:i, raw('&nbsp;'), :class => 'label', :style => 'background-color:' + COLORS[label]) +
      raw('&nbsp;') +
      link_to(name, path, :class => 'dashboard-links') +
      content_tag(:h4, @report[label])
    end
  end

  def compliance_widget(opts)
    name = opts.delete(:name)
    template = opts.delete(:template)
    widget = Widget.new(opts)
    widget.name = name
    widget.template = template
    widget
  end

  def assigned_icon(policy, arf_report)
    if arf_report.host.combined_policies.include? policy
      icon = 'check'
      tooltip_text = _('Host is assigned to policy')
    else
      icon = 'close'
      tooltip_text = _('Host is not assigned to policy but reports were found. You may want to delete the reports or assign the policy again.')
    end
    trunc_with_tooltip icon_text(icon, '', :kind => 'fa'), 32, tooltip_text, false
  end

  def unassigned_hosts_link
    trunc_with_tooltip(
      link_to(
        _("Hosts no longer assigned: %s") % @report[:unassigned_hosts],
        hosts_path(:search => "removed_from_policy = \"#{@policy.name}\"")
      ),
      32,
      _("Total hosts with reports where policy is no longer assigned."),
      false
    )
  end
end
