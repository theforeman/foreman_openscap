module ForemanOpenscap
  module HostExtensions
    ::Host::Managed::Jail.allow :policies_enc

    def self.prepended(base)
      base.has_one :asset, :as => :assetable, :class_name => "::ForemanOpenscap::Asset"
      base.has_many :asset_policies, :through => :asset, :class_name => "::ForemanOpenscap::AssetPolicy"
      base.has_many :policies, :through => :asset_policies, :class_name => "::ForemanOpenscap::Policy"
      base.has_many :arf_reports, :class_name => '::ForemanOpenscap::ArfReport', :foreign_key => :host_id
      base.has_one :compliance_status_object, :class_name => '::ForemanOpenscap::ComplianceStatus', :foreign_key => 'host_id'

      base.scoped_search :relation => :policies, :on => :name, :complete_value => true, :rename => :compliance_policy,
                    :only_explicit => true, :operators => ['= '], :ext_method => :search_by_policy_name

      base.scoped_search :relation => :policies, :on => :id, :complete_value => false, :rename => :compliance_policy_id,
                    :only_explicit => true, :operators => ['= ', '!= '], :ext_method => :search_by_policy_id

      base.scoped_search :relation => :policies, :on => :name, :complete_value => true, :rename => :compliance_report_missing_for,
                    :only_explicit => true, :operators => ['= ', '!= '], :ext_method => :search_by_missing_arf

      base.scoped_search :relation => :compliance_status_object, :on => :status, :rename => :compliance_status,
                    :complete_value => { :compliant => ::ForemanOpenscap::ComplianceStatus::COMPLIANT,
                                         :incompliant => ::ForemanOpenscap::ComplianceStatus::INCOMPLIANT,
                                         :inconclusive => ::ForemanOpenscap::ComplianceStatus::INCONCLUSIVE }

      base.scoped_search :relation => :policies, :on => :name, :complete_value => { :true => true, :false => false },
                         :only_explicit => true, :rename => :is_compliance_host, :operators => ['= '], :ext_method => :search_for_any_with_policy,
                         :validator => ->(value) { ['true', 'false'].include? value }

      base.scoped_search :on => :id, :rename => :passes_xccdf_rule,
              :only_explicit => true, :operators => ['= '], :ext_method => :search_by_rule_passed

      base.scoped_search :on => :id, :rename => :fails_xccdf_rule,
              :only_explicit => true, :operators => ['= '], :ext_method => :search_by_rule_failed

      base.scoped_search :on => :id, :rename => :others_xccdf_rule,
              :only_explicit => true, :operators => ['= '], :ext_method => :search_by_rule_othered

      base.after_update :puppetrun!, :if => ->(host) do
        Setting[:puppetrun] &&
        host.changed.include?('openscap_proxy_id') &&
        (host.individual_puppetclasses + host.parent_classes).pluck(:name).include?(ClientConfig::Puppet.new.puppetclass_name)
      end

      base.scope :comply_with, lambda { |policy|
        joins(:arf_reports).merge(ArfReport.latest_of_policy(policy)).merge(ArfReport.passed)
      }

      base.scope :incomply_with, lambda { |policy|
        joins(:arf_reports).merge(ArfReport.latest_of_policy(policy)).merge(ArfReport.failed)
      }

      base.scope :inconclusive_with, lambda { |policy|
        joins(:arf_reports).merge(ArfReport.latest_of_policy(policy)).merge(ArfReport.othered)
      }

      base.scope :policy_reports_missing, lambda { |policy|
        search_for("compliance_report_missing_for = \"#{policy.name}\"")
      }

      base.scope :assigned_to_policy, lambda { |policy|
        search_for("compliance_policy = \"#{policy.name}\"")
      }

      base.send :extend, ClassMethods
    end

    def inherited_attributes
      super.concat(%w[openscap_proxy_id])
    end

    def policies=(policies)
      self.build_asset(:assetable => self) if self.asset.blank?
      self.asset.policies = policies
    end

    def get_asset
      ForemanOpenscap::Asset.where(:assetable_type => 'Host::Base', :assetable_id => id).first_or_create!
    end

    def policies_enc
      check = ForemanOpenscap::OpenscapProxyAssignedVersionCheck.new(self).run
      method = check.pass? ? :to_enc : :to_enc_legacy
      combined_policies.map(&method).to_json
    end

    def combined_policies
      inc = %i[scap_content scap_content_profile tailoring_file tailoring_file_profile]
      combined = self.hostgroup ? self.policies.includes(inc) + self.hostgroup.policies.includes(inc) + self.hostgroup.inherited_policies : self.policies.includes(inc)
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
        ForemanOpenscap::ArfReport.joins(:policy_arf_report)
                                  .merge(ForemanOpenscap::PolicyArfReport.of_policy(policy.id)).where(:host_id => id).limit limit
      else
        ForemanOpenscap::ArfReport.joins(:policy_arf_report)
                                  .merge(ForemanOpenscap::PolicyArfReport.of_policy(policy.id)).where(:host_id => id)
      end
    end

    def compliance_status(options = {})
      @compliance_status ||= get_status(ForemanOpenscap::ComplianceStatus).to_status(options)
    end

    def compliance_status_label(options = {})
      @compliance_status_label ||= get_status(ForemanOpenscap::ComplianceStatus).to_label(options)
    end

    module ClassMethods
      def search_by_rule_passed(key, operator, rule_name)
        search_by_rule rule_name, 'pass'
      end

      def search_by_rule_failed(key, operator, rule_name)
        search_by_rule rule_name, 'fail'
      end

      def search_by_rule_othered(key, operator, rule_name)
        search_by_rule rule_name, LogExtensions.othered_result_constants
      end

      def search_by_rule(rule_name, rule_result)
        query = Host.joins(:arf_reports)
                    .merge(ArfReport.latest
                                    .by_rule_result(rule_name, rule_result)
                                    .unscope(:order))
                    .distinct
                    .select(Host.arel_table[:id]).to_sql

        query_conditions query
      end

      def query_conditions(query)
        { :conditions => "hosts.id IN (#{query})" }
      end

      def search_by_policy_name(key, operator, policy_name)
        cond = sanitize_sql_for_conditions(["foreman_openscap_policies.name #{operator} ?", value_to_sql(operator, policy_name)])

        host_group_host_ids = policy_assigned_using_hostgroup_host_ids cond, []
        host_group_cond = if host_group_host_ids.any?
                            ' OR ' + sanitize_sql_for_conditions("hosts.id IN (#{host_group_host_ids.join(',')})")
                          else
                            ''
                          end
        { :conditions => Host::Managed.arel_table[:id].in(Host::Managed.select(Host::Managed.arel_table[:id]).joins(:policies).where(cond).pluck(:id)).to_sql + host_group_cond }
      end

      def search_by_policy_id(key, operator, policy_id)
        cond = sanitize_sql_for_conditions(["foreman_openscap_policies.id #{operator} ?", value_to_sql(operator, policy_id)])
        search_assigned_all cond, []
      end

      def search_by_missing_arf(key, operator, policy_name)
        cond = sanitize_sql_for_conditions(["foreman_openscap_policies.name #{operator} ?", value_to_sql(operator, policy_name)])

        host_ids_from_arf_of_policy = ForemanOpenscap::ArfReport.joins(:policy).where(cond).pluck(:host_id).uniq

        search_assigned_all cond, host_ids_from_arf_of_policy
      end

      def search_for_any_with_policy(key, operator, value)
        search_assigned_all nil, [], (value == "false")
      end

      def search_assigned_all(condition, not_in_host_ids, negate = false)
        sql_not = negate ? "NOT" : ""
        direct_result = policy_assigned_directly_host_ids condition, not_in_host_ids
        hg_result = policy_assigned_using_hostgroup_host_ids condition, not_in_host_ids
        result = (direct_result + hg_result).uniq
        { :conditions => "hosts.id #{sql_not} IN (#{result.empty? ? 'NULL' : result.join(',')})" }
      end

      def policy_assigned_directly_host_ids(condition, host_ids_from_arf)
        ForemanOpenscap::Asset.where(:assetable_type => 'Host::Base')
                              .joins(:policies)
                              .where(condition)
                              .where.not(:assetable_id => host_ids_from_arf)
                              .pluck(:assetable_id)
      end

      def policy_assigned_using_hostgroup_host_ids(condition, host_ids_from_arf)
        hostgroup_with_policy_ids = ForemanOpenscap::Asset.where(:assetable_type => 'Hostgroup')
                                                          .joins(:policies)
                                                          .where(condition)
                                                          .pluck(:assetable_id)
        subtree_ids = Hostgroup.where(:id => hostgroup_with_policy_ids).flat_map(&:subtree_ids).uniq
        Host.where(:hostgroup_id => subtree_ids).where.not(:id => host_ids_from_arf).pluck(:id)
      end
    end
  end
end
