#
# Copyright (c) 2014 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 3 (GPLv3). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv3
# along with this software; if not, see http://www.gnu.org/licenses/gpl.txt
#

module Scaptimony::PolicyDashboard
  class Loader
    def self.load
      Scaptimony::PolicyDashboard::Manager.map do |dashboard|
        dashboard.widget 'policy_status_widget', :row=>1,:col=>1,:sizex=>8,:sizey=>1,:name=> N_('Status table')
        dashboard.widget 'policy_chart_widget',  :row=>1,:col=>9,:sizex=>4,:sizey=>1,:name=> N_('Status chart')
      end
    end
  end
end
