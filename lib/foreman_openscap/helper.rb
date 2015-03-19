#
# Copyright (c) 2014 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 3 (GPLv3). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv3
# along with this software; if not, see http://www.gnu.org/licenses/gpl.txt
#

module ForemanOpenscap::Helper
  def self.get_asset(cname, policy_id)
    asset = Host.find_by_name!(cname).get_asset
    asset.policy_ids += [policy_id]
    asset
  end
end
