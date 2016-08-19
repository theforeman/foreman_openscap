#
# Copyright (c) 2014 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 3 (GPLv3). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv3
# along with this software; if not, see http://www.gnu.org/licenses/gpl.txt
#

module ComplianceDashboardHelper

  def latest_compliance_headers
    string =  "<th>#{_("Host")}</th>"
    string += "<th>#{_("Policy")}</th>"
    # TRANSLATORS: initial character of Passed
    string += translated_header(s_('Passed|P'), _('Passed'))
    # TRANSLATORS: initial character of Failed
    string += translated_header(s_('Failed|F'), _('Failed'))
    # TRANSLATORS: initial character of Othered which is an SCAP term
    string += translated_header(s_('Othered|O'), _('Othered'))

    string.html_safe
  end

end
