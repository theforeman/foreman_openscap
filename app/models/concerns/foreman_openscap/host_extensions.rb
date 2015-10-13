module ForemanOpenscap
  module HostExtensions
    extend ActiveSupport::Concern
    ::Host::Managed::Jail.allow :policies_enc

    included do
      has_one :asset, :as => :assetable, :class_name => "::ForemanOpenscap::Asset"
      has_many :asset_policies, :through => :asset, :class_name => "::ForemanOpenscap::AssetPolicy"
      has_many :policies, :through => :asset_policies, :class_name => "::ForemanOpenscap::Policy"
      has_many :arf_reports, :through => :asset, :class_name => '::ForemanOpenscap::ArfReport'
      has_one :compliance_status_object, :class_name => '::ForemanOpenscap::ComplianceStatus', :foreign_key => 'host_id'

      scoped_search :in => :policies, :on => :name, :complete_value => true, :rename => :'compliance_policy',
                    :only_explicit => true, :operators => ['= ', '!= '], :ext_method => :search_by_policy_name
      scoped_search :in => :policies, :on => :name, :complete_value => true, :rename => :'compliance_report_missing_for',
                    :only_explicit => true, :operators => ['= ', '!= '], :ext_method => :search_by_missing_arf
      scoped_search :in => :compliance_status_object, :on => :status, :rename => :compliance_status,
                    :complete_value => {:compliant => ::ForemanOpenscap::ComplianceStatus::COMPLIANT,
                                        :incompliant => ::ForemanOpenscap::ComplianceStatus::INCOMPLIANT,
                                        :inconclusive => ::ForemanOpenscap::ComplianceStatus::INCONCLUSIVE}
    end

    def get_asset
      ForemanOpenscap::Asset.where(:assetable_type => 'Host::Base', :assetable_id => id).first_or_create!
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

    def last_report_for_policy(policy)
      reports_for_policy(policy, 1)
    end

    def reports_for_policy(policy, limit = nil)
      if limit
        ForemanOpenscap::ArfReport.where(:asset_id => asset.id, :policy_id => policy.id).limit limit
      else
        ForemanOpenscap::ArfReport.where(:asset_id => asset.id, :policy_id => policy.id)
      end
    end

    def compliance_status(options = {})
      @compliance_status ||= get_status(ForemanOpenscap::ComplianceStatus).to_status(options)
    end

    def compliance_status_label(options = {})
      @compliance_status_label ||= get_status(ForemanOpenscap::ComplianceStatus).to_label(options)
    end

    module ClassMethods
      def search_by_policy_name(key, operator, policy_name)
        cond = sanitize_sql_for_conditions(["foreman_openscap_policies.name #{operator} ?", value_to_sql(operator, policy_name)])
        { :conditions => Host::Managed.arel_table[:id].in(
              Host::Managed.select(Host::Managed.arel_table[:id]).joins(:policies).where(cond).ast
            ).to_sql }
      end

      def search_by_missing_arf(key, operator, policy_name)
        cond = sanitize_sql_for_conditions(["foreman_openscap_policies.name #{operator} ?", value_to_sql(operator, policy_name)])
        { :conditions => Host::Managed.arel_table[:id].in(
             Host::Managed.select(Host::Managed.arel_table[:id])
               .joins(:policies)
               .where(cond)
               .where('foreman_openscap_assets.id not in (
				SELECT distinct foreman_openscap_arf_reports.asset_id
				FROM foreman_openscap_arf_reports
				WHERE foreman_openscap_arf_reports.asset_id = foreman_openscap_assets.id
					AND foreman_openscap_arf_reports.policy_id = foreman_openscap_policies.id)
			')
               .ast
             ).to_sql
        }
      end
    end
  end
end
