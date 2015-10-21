module ForemanOpenscap
  module KatelloSystemExtensions
    extend ActiveSupport::Concern

    included do
      has_one :asset, :as => :assetable, :class_name => '::ForemanOpenscap::Asset'
      has_many :asset_policies, :through => :asset, :class_name => '::ForemanOpenscap::AssetPolicy'
      has_many :policies, :through => :asset_policies, :class_name => '::ForemanOpenscap::Policy'
      has_many :arf_reports, :through => :asset, :class_name => '::ForemanOpenscap::ArfReport'
      after_save :migrate_asset_to_foreman_host
    end

    def get_asset
      host_id ?
          ForemanOpenscap::Asset.where(:assetable_type => 'Host::Base', :assetable_id => host_id).first_or_create! :
          ForemanOpenscap::Asset.where(:assetable_type => 'Katello::System', :assetable_id => id).first_or_create!
    end

    private
    def migrate_asset_to_foreman_host
      asset.update_attributes(:assetable_type => 'Host::Base', :assetable_id => host_id) if (asset && host_id)
    end
  end
end