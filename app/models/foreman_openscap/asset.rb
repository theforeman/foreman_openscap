module ForemanOpenscap
  class Asset < ActiveRecord::Base
    has_many :asset_policies
    has_many :policies, :through => :asset_policies
    belongs_to :assetable, :polymorphic => true

    scope :hosts, where(:assetable_type => 'Host::Base')

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
