module ForemanOpenscap
  module HostgroupExtensions
    extend ActiveSupport::Concern

    include InheritedPolicies

    included do
      has_many :assets, :as => :assetable, :class_name => "::ForemanOpenscap::Asset", dependent: :destroy
      has_many :asset_policies, :through => :assets, :class_name => "::ForemanOpenscap::AssetPolicy"
      has_many :policies, :through => :asset_policies, :class_name => "::ForemanOpenscap::Policy"
    end

    def inherited_policies
      find_inherited_policies :policies
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
