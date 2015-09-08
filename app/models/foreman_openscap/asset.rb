module ForemanOpenscap
  class Asset < ActiveRecord::Base
    has_many :asset_policies
    has_many :policies, :through => :asset_policies
    has_many :arf_reports, :dependent => :destroy
    belongs_to :assetable, :polymorphic => true

    scope :hosts, where(:assetable_type => 'Host::Base')
    scope :policy_reports, lambda { |policy| includes(:arf_reports).where(:foreman_openscap_arf_reports => { :policy_id => policy.id }) }
    scope :policy_reports_missing, lambda { |policy|
      where("id NOT IN (select asset_id from foreman_openscap_arf_reports where policy_id = #{policy.id})")
    }
    scope :comply_with, lambda { |policy|
      last_arf(policy).breakdown.where(:foreman_openscap_arf_report_breakdowns => { :failed => 0, :othered => 0 })
    }
    scope :incomply_with, lambda { |policy|
      last_arf(policy).breakdown.where('foreman_openscap_arf_report_breakdowns.failed != 0') # TODO:RAILS-4.0: rewrite with: where.not()
    }
    scope :inconclusive_with, lambda { |policy|
      last_arf(policy).breakdown.
        where(:foreman_openscap_arf_report_breakdowns => { :failed => 0, :othered => 0 }).
        where('foreman_openscap_arf_report_breakdowns.failed != 0') # TODO:RAILS-4.0: rewrite with: where.not()
    }
    scope :breakdown, joins('INNER JOIN foreman_openscap_arf_report_breakdowns
      ON foreman_openscap_arf_reports.id = foreman_openscap_arf_report_breakdowns.arf_report_id')
    scope :last_arf, lambda { |policy|
      joins("-- this is emo, we need some hipsters to rewrite this using arel
             INNER JOIN (select asset_id, max(id) AS id
             FROM foreman_openscap_arf_reports
             WHERE policy_id = #{policy.id}
             GROUP BY asset_id) foreman_openscap_arf_reports
             ON foreman_openscap_arf_reports.asset_id = foreman_openscap_assets.id")
    }

    def host
      fetch_asset('Host::Base')
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
