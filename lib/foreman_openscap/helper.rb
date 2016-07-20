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
    asset = find_host_by_name_or_uuid(cname).get_asset
    asset.policy_ids += [policy_id]
    asset
  end

  def self.find_name_or_uuid_by_host(host)
    (host.respond_to?(:subscription_facet) && !host.subscription_facet.nil?) ? host.subscription_facet.try(:uuid) : host.name
  end

  private

  def self.find_host_by_name_or_uuid(cname)
    if Facets.registered_facets.keys.include?(:subscription_facet)
      host = Katello::Host::SubscriptionFacet.find_by_uuid(cname).try(:host)
      host ||= Host.find_by_name(cname)
    else
      host = Host.find_by_name(cname)
    end

    unless host
      Rails.logger.error "Could not find Host with name: #{cname}"
      fail ActiveRecord::RecordNotFound
    end
    host
  end
end
