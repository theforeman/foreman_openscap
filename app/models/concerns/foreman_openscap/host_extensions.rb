require 'scaptimony/asset'

module ForemanOpenscap
  module HostExtensions
    extend ActiveSupport::Concern

    included do
      has_many :assets, :as => :assetable, :class_name => "::Scaptimony::Asset"

      has_many :policies, :through => :assets, :class_name => '::Scaptimony::Policy'
      has_many :arf_reports, :through => :assets, :class_name => '::Scaptimony::ArfReport'

      scope :comply_with, lambda { |policy|
                          last_arf(policy).breakdown.where(:scaptimony_arf_report_breakdowns => {:failed => 0, :othered => 0})
                        }
      scope :incomply_with, lambda { |policy|
                            last_arf(policy).breakdown.where('scaptimony_arf_report_breakdowns.failed != 0') # TODO:RAILS-4.0: rewrite with: where.not()
                          }
      scope :inconclusive_with, lambda { |policy|
                                last_arf(policy).breakdown.
                                    where(:scaptimony_arf_report_breakdowns => {:failed => 0, :othered => 0}).
                                    where('scaptimony_arf_report_breakdowns.failed != 0') # TODO:RAILS-4.0: rewrite with: where.not()
                              }

      scope :policy_reports, lambda { |policy| includes(:arf_reports).where(:scaptimony_arf_reports => { :policy_id => policy.id }) }
      scope :policy_reports_missing, lambda { |policy|
                                     where("id NOT IN (select asset_id from scaptimony_arf_reports where policy_id = #{policy.id})")
                                   }

      scoped_search :in => :policies, :on => :name, :complete_value => true, :rename => :'compliance_policy',
                    :only_explicit => true, :operators => ['= ', '!= '], :ext_method => :search_by_policy_name
      scoped_search :in => :policies, :on => :name, :complete_value => true, :rename => :'compliance_report_missing_for',
                    :only_explicit => true, :operators => ['= ', '!= '], :ext_method => :search_by_missing_arf
    end

    def get_asset(policy_name)
      policy = Scaptimony::Policy.find_by_name!(policy_name)
      # TODO:RAILS-4.0: This should become: asset = Asset.find_or_create_by!(name: cname)
      Scaptimony::Asset.where(:assetable_type => 'Host::Base', :assetable_id => id, :policy_id => policy.id).first_or_create!
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
