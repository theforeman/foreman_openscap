module ArfReportDashboardHelper
  COLORS = {
    :passed => '#89A54E',
    :failed => '#AA4643',
    :othered => '#DB843D',
  }.freeze

  def reports_breakdown_chart(report, options = {})
    data = []
    [[:failed, _('Failed')],
     [:passed, _('Passed')],
     [:othered, _('Othered')],].each do |i|
      data << {:label => i[1], :data => report[i[0]], :color => COLORS[i[0]]}
    end
    flot_pie_chart 'overview', _('Compliance reports breakdown'), data, options
  end
end
