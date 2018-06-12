module ForemanOpenscap
  module ComplianceStatusScopedSearch
    extend ActiveSupport::Concern

    module ClassMethods
      def compliance_status_scoped_search(status, options = {})
        options[:offset] = ArfReport::METRIC.index(status.to_s)
        options[:word_size] = ArfReport::BIT_NUM
        scoped_search options
      end

      def policy_search(search_alias)
        scoped_search :relation => :policy, :on => :name, :complete_value => true, :rename => search_alias,
              :only_explicit => true, :ext_method => :search_by_policy_name
      end

      def search_by_policy_name(_key, _operator, policy_name)
        query = PolicyArfReport.of_policy(Policy.find_by(:name => policy_name))
                               .select(PolicyArfReport.arel_table[:arf_report_id]).to_sql
        query_conditions query
      end

      def search_by_comply_with(_key, _operator, policy_name)
        search_by_policy_results policy_name, &:passed
      end

      def search_by_not_comply_with(_key, _operator, policy_name)
        search_by_policy_results policy_name, &:failed
      end

      def search_by_inconclusive_with(_key, _operator, policy_name)
        search_by_policy_results policy_name, &:othered
      end

      def search_by_policy_results(policy_name, &selection)
        query = ArfReport.of_policy(Policy.find_by(:name => policy_name).id)
                         .instance_eval(&selection).select(ArfReport.arel_table[:id]).to_sql
        query_conditions query
      end

      def search_by_last_for(key, operator, by)
        by.gsub!(/[^[:alnum:]]/, '')
        case by.downcase
        when 'host'
          { :conditions => 'reports.id IN (
                SELECT MAX(id) FROM reports sub
                WHERE sub.host_id = reports.host_id)' }
        when 'policy'
          { :conditions => 'reports.id IN (
              SELECT latest.id
              FROM foreman_openscap_policies
                INNER JOIN (SELECT policy_id, MAX(reports.id) AS id
                            FROM reports INNER JOIN foreman_openscap_policy_arf_reports
                              ON reports.id = foreman_openscap_policy_arf_reports.arf_report_id
                            GROUP BY policy_id
                           ) latest
                ON foreman_openscap_policies.id = latest.policy_id)' }
        else
          raise "Cannot search last by #{by}"
        end
      end

      private

      def query_conditions(query)
        { :conditions => "reports.id IN (#{query})" }
      end
    end

    included do
      policy_search :compliance_policy

      policy_search :policy

      scoped_search :on => :id, :rename => :last_for, :complete_value => { :host => 0, :policy => 1 },
                    :only_explicit => true, :ext_method => :search_by_last_for

      scoped_search :relation => :policy, :on => :name, :complete_value => true, :rename => :comply_with,
                    :only_explicit => true, :operators => ['= '], :ext_method => :search_by_comply_with

      scoped_search :relation => :policy, :on => :name, :complete_value => true, :rename => :not_comply_with,
                    :only_explicit => true, :operators => ['= '], :ext_method => :search_by_not_comply_with

      scoped_search :relation => :policy, :on => :name, :complete_value => true, :rename => :inconclusive_with,
                    :only_explicit => true, :operators => ['= '], :ext_method => :search_by_inconclusive_with

      scoped_search :relation => :openscap_proxy, :on => :name, :complete_value => true, :only_explicit => true, :rename => :openscap_proxy

      compliance_status_scoped_search 'passed', :on => :status, :rename => :compliance_passed
      compliance_status_scoped_search 'failed', :on => :status, :rename => :compliance_failed
      compliance_status_scoped_search 'othered', :on => :status, :rename => :compliance_othered
    end
  end
end
