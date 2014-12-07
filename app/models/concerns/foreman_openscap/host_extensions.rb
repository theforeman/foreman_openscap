require 'scaptimony/asset'

module ForemanOpenscap
  module HostExtensions
    extend ActiveSupport::Concern

    included do
      has_one :auditable_host, :class_name => "::Scaptimony::AuditableHost",
          :foreign_key => :host_id, :inverse_of => :host
    end

    def get_asset
      return auditable_host.asset unless auditable_host.nil?
      # TODO:RAILS-4.0: This should become: asset = Asset.find_or_create_by!(name: cname)
      asset = Scaptimony::Asset.first_or_create!(:name => name)
      @auditable_host = Scaptimony::AuditableHost.where(:asset_id => asset.id, :host_id => id).first_or_create
      @auditable_host.asset
    end

    module ClassMethods
      # create or overwrite class methods...
      def class_method_name
      end
    end

  end
end
