require 'scaptimony/asset'

module ForemanOpenscap
  module HostExtensions
    extend ActiveSupport::Concern

    included do
      has_one :auditable_host, :class_name => "::Scaptimony::AuditableHost",
          :foreign_key => :host_id, :inverse_of => :host
      has_one :asset, :through => :auditable_host, :class_name => "::Scaptimony::Asset"
      has_many :asset_policies, :through => :asset, :class_name => "::Scaptimony::AssetPolicy"
      has_many :policies, :through => :asset_policies, :class_name => "::Scaptimony::Policy"

      scoped_search :in => :policies, :on => :name, :complete_value => true, :rename => :'compliance_policy',
                    :only_explicit => true, :operators => ['= ', '!= '], :ext_method => :search_by_policy_name
      scoped_search :in => :policies, :on => :name, :complete_value => true, :rename => :'compliance_report_missing_for',
                    :only_explicit => true, :operators => ['= ', '!= '], :ext_method => :search_by_missing_arf
    end

    def get_asset
      return auditable_host.asset unless auditable_host.nil?
      # TODO:RAILS-4.0: This should become: asset = Asset.find_or_create_by!(name: cname)
      asset = Scaptimony::Asset.where(:name => name).first_or_create!
      @auditable_host = Scaptimony::AuditableHost.where(:asset_id => asset.id, :host_id => id).first_or_create!
      @auditable_host.asset
    end

    module ClassMethods
      def search_by_policy_name(key, operator, policy_name)
        cond = sanitize_sql_for_conditions(["scaptimony_policies.name #{operator} ?", value_to_sql(operator, policy_name)])
        { :conditions => Host::Managed.arel_table[:id].in(Host::Managed.select('hosts.id').joins(:policies).where(cond).ast).to_sql }
      end

      def search_by_missing_arf(key, operator, policy_name)
        cond = sanitize_sql_for_conditions(["scaptimony_policies.name #{operator} ?", value_to_sql(operator, policy_name)])
        { :conditions => Host::Managed.arel_table[:id].in(
             Host::Managed.select('hosts.id')
               .joins(:policies)
               .where(cond)
               .where('scaptimony_assets.id not in (
				SELECT distinct scaptimony_arf_reports.asset_id
				FROM scaptimony_arf_reports
				WHERE scaptimony_arf_reports.asset_id = scaptimony_assets.id
					AND scaptimony_arf_reports.policy_id = scaptimony_policies.id)
			')
               .ast
             ).to_sql
        }
      end
    end
  end
end
