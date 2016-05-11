#
# Copyright (c) 2014 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 3 (GPLv3). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv3
# along with this software; if not, see http://www.gnu.org/licenses/gpl.txt
#

module PolicyDashboardHelper
  COLORS = {
    :compliant_hosts => ArfReportDashboardHelper::COLORS[:passed],
    :incompliant_hosts => ArfReportDashboardHelper::COLORS[:failed],
    :inconclusive_hosts => ArfReportDashboardHelper::COLORS[:othered],
    :report_missing => '#92A8CD',
  }

  def host_breakdown_chart(report, options = {})
    data = []
    [[:compliant_hosts, _('Compliant hosts')],
     [:incompliant_hosts, _('Incompliant hosts')],
     [:inconclusive_hosts, _('Inconclusive')],
     [:report_missing, _('Not audited')],
    ].each do |i|
      data << {:label => i[1], :data => report[i[0]], :color => COLORS[i[0]]}
    end
    flot_pie_chart 'overview', _('Compliance Status'), data, options
  end

  def status_link(name, label, path)
    content_tag :li do
      content_tag(:i, raw('&nbsp;'), :class=>'label', :style => 'background-color:' + COLORS[label]) +
      raw('&nbsp;') +
      link_to(name, path, :class=>'dashboard-links') +
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
end
