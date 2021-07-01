module ArfReportDashboardHelper
  COLORS = {
    :passed => '#89A54E',
    :failed => '#AA4643',
    :othered => '#DB843D',
  }.freeze

  def breakdown_chart_data(categories, report, colors = COLORS)
    categories.reduce([]) do |memo, (key, value)|
      memo << [value, report[key], colors[key]]
    end
  end

  def donut_breakdown_chart_data(report)
    categories = {
      :failed => _('Failed'),
      :passed => _('Passed'),
      :othered => _('Other')
    }
    breakdown_chart_data categories, report
  end

  def arf_report_status_chart_data(status)
    {
      :data => status.to_a,
      :yAxisLabel => _("Number of Events"),
      :xAxisLabel => _("Rule Results"),
    }
  end
end
