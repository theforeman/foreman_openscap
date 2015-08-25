module ForemanOpenscap
  module HostgroupExtensions
    extend ActiveSupport::Concern

    included do
      has_one :asset, :as => :assetable, :class_name => "::ForemanOpenscap::Asset"
      has_many :asset_policies, :through => :asset, :class_name => "::ForemanOpenscap::AssetPolicy"
      has_many :policies, :through => :asset_policies, :class_name => "::ForemanOpenscap::Policy"
    end
  end
end
