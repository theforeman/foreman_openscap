module ForemanOpenscap
  class Asset < ApplicationRecord
    has_many :asset_policies, :dependent => :delete_all
    has_many :policies, :through => :asset_policies
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

    def fetch_asset(type)
      assetable if assetable_type == type
    end
  end
end
