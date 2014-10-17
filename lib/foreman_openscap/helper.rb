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
  def self.get_asset(cname)
    host = Host.find_by_name!(cname)
    if host.auditable_host.nil?
      # TODO:RAILS-4.0: This should become: asset = Asset.find_or_create_by!(name: cname)
      asset = Scaptimony::Asset.first_or_create!(:name => cname)
      host.auditable_host = Scaptimony::AuditableHost.where(:asset_id => asset.id, :host_id => host.id).first_or_create
    end
    return host.auditable_host.asset
  end
end
