module ForemanOpenscap
  class Asset < ApplicationRecord
    has_many :asset_policies, :dependent => :delete_all
    has_many :policies, :through => :asset_policies,
                        :after_add => :reset_compliance_status,
                        :after_remove => :reset_compliance_status
    belongs_to :assetable, :polymorphic => true

    scope :hosts, lambda { where(:assetable_type => 'Host::Base') }

    def host
      fetch_asset('Host::Base')
    end

    def hostgroup
      fetch_asset('Hostgroup')
    end

    def name
      assetable.name
    end

    private

    def reset_compliance_status(_policy)
      ForemanOpenscap::ComplianceStatusResetter.to_inconclusive(host_ids_reached_by_asset)
    end

    def host_ids_reached_by_asset
      case assetable_type
      when 'Host::Base'
        [assetable_id]
      when 'Hostgroup'
        hostgroup = Hostgroup.find_by(:id => assetable_id)
        return [] unless hostgroup

        Host.where(:hostgroup_id => hostgroup.subtree_ids).pluck(:id)
      else
        []
      end
    end

    def fetch_asset(type)
      assetable if assetable_type == type
    end
  end
end
