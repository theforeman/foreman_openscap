module ForemanOpenscap::Helper
  def self.get_asset(cname, policy_id)
    asset = find_host_by_name_or_uuid(cname)&.get_asset
    return unless asset
    asset.policy_ids += [policy_id]
    asset
  end

  def self.find_name_or_uuid_by_host(host)
    host.respond_to?(:subscription_facet) && !host.subscription_facet.nil? ? host.subscription_facet.try(:uuid) : host.name
  end

  def self.find_host_by_name_or_uuid(cname)
    if Facets.registered_facets.keys.include?(:subscription_facet)
      host = Katello::Host::SubscriptionFacet.find_by(uuid: cname).try(:host)
      host ||= Host.find_by(name: cname)
    else
      host = Host.find_by(name: cname)
    end
  end
end
