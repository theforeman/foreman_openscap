#
# Copyright (c) 2014 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 3 (GPLv3). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv3
# along with this software; if not, see http://www.gnu.org/licenses/gpl.txt
#

module ScaptimonyPolicyDashboardHelper
  Colors = {
    :compliant_hosts => '#89A54E',
    :incompliant_hosts => '#AA4643',
    :inconclusive_hosts => '#DB843D',
    :report_missing => '#92A8CD',
  }

  def policy_widget_list
    Scaptimony::PolicyDashboard::Manager.widgets
  end

  def host_breakdown_chart(report, options = {})
    data = []
    [[:compliant_hosts, _('Compliant hosts')],
     [:incompliant_hosts, _('Incompliant hosts')],
     [:inconclusive_hosts, _('Inconclusive')],
     [:report_missing, _('Not audited')],
    ].each { |i|
      data << {:label => i[1], :data => report[i[0]], :color => Colors[i[0]]}
    }
    flot_pie_chart 'overview', _('Compliance Status'), data, options
  end

  def status_link(name, label, path)
    content_tag :li do
      content_tag(:i, raw('&nbsp;'), :class=>'label', :style => 'background-color:' + Colors[label]) +
      raw('&nbsp;') +
      link_to(name, path, :class=>'dashboard-links') +
      content_tag(:h4, @report[label])
    end
  end
end
