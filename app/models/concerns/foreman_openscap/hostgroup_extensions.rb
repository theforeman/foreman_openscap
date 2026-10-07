module ForemanOpenscap
  module HostgroupExtensions
    extend ActiveSupport::Concern

    include InheritedPolicies

    included do
      has_many :assets, :as => :assetable, :class_name => "::ForemanOpenscap::Asset", dependent: :destroy
      has_many :asset_policies, :through => :assets, :class_name => "::ForemanOpenscap::AssetPolicy"
      has_many :policies, :through => :asset_policies, :class_name => "::ForemanOpenscap::Policy"

      after_update :reset_compliance_status_on_ancestry_change, :if => :saved_change_to_ancestry?
    end

    def inherited_policies
      find_inherited_policies :policies
    end

    def reset_compliance_status_on_ancestry_change
      host_ids = ::Host.where(:hostgroup_id => subtree_ids).pluck(:id)
      ForemanOpenscap::ComplianceStatusResetter.to_inconclusive(host_ids)
    end

    def openscap_proxy
      return super if ancestry.nil? || self.openscap_proxy_id.present?
      ::SmartProxy.find_by(:id => inherited_openscap_proxy_id)
    end

    def inherited_openscap_proxy_id
      if ancestry.present?
        self[:openscap_proxy_id] || self.class.sort_by_ancestry(ancestors.where.not(openscap_proxy_id: nil)).last.try(:openscap_proxy_id)
      else
        self.send(:openscap_proxy_id)
      end
    end
  end
end
