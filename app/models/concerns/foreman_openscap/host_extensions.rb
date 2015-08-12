require 'scaptimony/asset'

module ForemanOpenscap
  module HostExtensions
    extend ActiveSupport::Concern
    ::Host::Managed::Jail.allow :policies_enc

    included do
      has_one :asset, :as => :assetable, :class_name => "::Scaptimony::Asset"
      has_many :asset_policies, :through => :asset, :class_name => "::Scaptimony::AssetPolicy"
      has_many :policies, :through => :asset_policies, :class_name => "::Scaptimony::Policy"
      has_many :arf_reports, :through => :asset, :class_name => '::Scaptimony::ArfReport'

      scoped_search :in => :policies, :on => :name, :complete_value => true, :rename => :'compliance_policy',
                    :only_explicit => true, :operators => ['= ', '!= '], :ext_method => :search_by_policy_name
      scoped_search :in => :policies, :on => :name, :complete_value => true, :rename => :'compliance_report_missing_for',
                    :only_explicit => true, :operators => ['= ', '!= '], :ext_method => :search_by_missing_arf
    end

    def get_asset
      Scaptimony::Asset.where(:assetable_type => 'Host::Base', :assetable_id => id).first_or_create!
    end

    def policies_enc
      combined_policies.map(&:to_enc).to_json
    end

    def combined_policies
      combined = self.hostgroup ? self.policies + self.hostgroup.policies : self.policies
      combined.uniq
    end

    def scap_status_changed?(policy)
      last_reports = reports_for_policy(policy, 2)
      return false if last_reports.length != 2
      !last_reports.first.equal? last_reports.last
    end

    def reports_for_policy(policy, limit = nil)
      if limit
        Scaptimony::ArfReport.where(:asset_id => asset.id, :policy_id => policy.id).limit limit
      else
        Scaptimony::ArfReport.where(:asset_id => asset.id, :policy_id => policy.id)
      end
    end

    module ClassMethods
      def search_by_policy_name(key, operator, policy_name)
        cond = sanitize_sql_for_conditions(["scaptimony_policies.name #{operator} ?", value_to_sql(operator, policy_name)])
        { :conditions => Host::Managed.arel_table[:id].in(
              Host::Managed.select(Host::Managed.arel_table[:id]).joins(:policies).where(cond).ast
            ).to_sql }
      end

      def search_by_missing_arf(key, operator, policy_name)
        cond = sanitize_sql_for_conditions(["scaptimony_policies.name #{operator} ?", value_to_sql(operator, policy_name)])
        { :conditions => Host::Managed.arel_table[:id].in(
             Host::Managed.select(Host::Managed.arel_table[:id])
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
