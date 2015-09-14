require 'digest'

module ForemanOpenscap
  class ArfReport < ActiveRecord::Base
    include Taxonomix

    belongs_to :asset
    belongs_to :policy
    delegate :assetable, :to => :asset, :as => :assetable
    has_many :xccdf_rule_results, :dependent => :destroy
    has_one :arf_report_raw, :dependent => :destroy
    has_one :arf_report_breakdown
    has_one :foreman_host, :through => :asset, :as => :assetable, :source => :assetable, :source_type => 'Host::Base'
    has_one :katello_system, :through => :asset, :as => :assetable, :source => :assetable, :source_type => 'Katello::System' rescue nil

    after_save :assign_locations_organizations

    default_scope {
      with_taxonomy_scope do
        order("foreman_openscap_arf_reports.created_at DESC")
      end
    }

    scope :hosts, lambda { includes(:policy, :arf_report_breakdown) }
    scope :latest, lambda { includes(:foreman_host, :policy, :arf_report_breakdown).limit(5).order("foreman_openscap_arf_reports.created_at DESC") }
    scope :of_policy, lambda {|policy_id| {:conditions => {:policy_id => policy_id}}}

    scope :breakdown, joins(:arf_report_breakdown)
    scope :comply, breakdown.where(:foreman_openscap_arf_report_breakdowns => { :failed => 0, :othered => 0 })
    scope :incomply, breakdown.where('foreman_openscap_arf_report_breakdowns.failed != 0') # TODO:RAILS-4.0: where.not
    scope :inconclusive, breakdown.where(:foreman_openscap_arf_report_breakdowns => { :failed => 0, :othered => 0 })
    scope :latest, joins('INNER JOIN (select asset_id, policy_id, max(id) AS id
                          FROM foreman_openscap_arf_reports
                          GROUP BY asset_id, policy_id) latest
                          ON foreman_openscap_arf_reports.id = latest.id')

    scoped_search :in => :host, :on => :name, :complete_value => :true, :rename => "host"
    scoped_search :on => :date, :complete_value => true, :default_order => :desc
    scoped_search :in => :arf_report_breakdown, :on => :passed
    scoped_search :in => :arf_report_breakdown, :on => :failed
    scoped_search :in => :arf_report_breakdown, :on => :othered
    scoped_search :in => :policy, :on => :name, :complete_value => true, :rename => :compliance_policy
    scoped_search :on => :id, :rename => :last_for, :complete_value => { :host => 0, :policy => 1 },
      :only_explicit => true, :ext_method => :search_by_last_for
    scoped_search :in => :policy, :on => :name, :complete_value => true, :rename => :comply_with,
      :only_explicit => true, :operators => ['= '], :ext_method => :search_by_comply_with
    scoped_search :in => :policy, :on => :name, :complete_value => true, :rename => :not_comply_with,
      :only_explicit => true, :operators => ['= '], :ext_method => :search_by_not_comply_with
    scoped_search :in => :policy, :on => :name, :complete_value => true, :rename => :inconclusive_with,
      :only_explicit => true, :operators => ['= '], :ext_method => :search_by_inconclusive_with

    def passed; arf_report_breakdown ? arf_report_breakdown.passed : 0; end
    def failed; arf_report_breakdown ? arf_report_breakdown.failed : 0; end
    def othered; arf_report_breakdown ? arf_report_breakdown.othered : 0; end

    def host
      return foreman_host unless defined?(Katello::System)
      foreman_host || katello_system
    end

    def to_html
      if arf_report_raw.nil?
        fail Error, "Cannot generate HTML report, ArfReport #{id} is missing XML details"
      end
      arf_report_raw.to_html
    end

    def self.create_arf(asset, params, arf_bzip, arf_bzip_size)
      # fail if policy does not exist.
      policy = Policy.find(params[:policy_id])
      digest = Digest::SHA256.hexdigest arf_bzip
      ArfReportRaw.transaction do
        # TODO:RAILS-4.0: This should become arf_report = ArfReport.find_or_create_by! ...
        arf_report = ArfReport.where(:asset_id => asset.id, :policy_id => policy.id,
                                     :date => params[:date], :digest => digest).first_or_create!
        if arf_report.arf_report_raw.nil?
          ArfReportRaw.where(:arf_report_id => arf_report.id, :size => arf_bzip_size, :bzip_data => arf_bzip).create!
        end
      end
    end

    def self.search_by_comply_with(_key, _operator, policy_name)
      search_by_policy_results policy_name, &:comply
    end

    def self.search_by_not_comply_with(_key, _operator, policy_name)
      search_by_policy_results policy_name, &:incomply
    end

    def self.search_by_inconclusive_with(_key, _operator, policy_name)
      search_by_policy_results policy_name, &:inconclusive
    end

    def self.search_by_policy_results(policy_name, &selection)
      cond = sanitize_sql_for_conditions('foreman_openscap_policies.name' => policy_name)
      { :conditions => ForemanOpenscap::ArfReport.arel_table[:id].in(
        ForemanOpenscap::ArfReport.select(ForemanOpenscap::ArfReport.arel_table[:id])
            .latest.instance_eval(&selection).joins(:policy).where(cond).ast
        ).to_sql
      }
    end

    def self.search_by_last_for(key, operator, by)
      by.gsub!(/[^[:alnum:]]/, '')
      case by.downcase
      when 'host'
        { :conditions => 'foreman_openscap_arf_reports.id IN (
              SELECT MAX(id) FROM foreman_openscap_arf_reports sub
              WHERE sub.asset_id = foreman_openscap_arf_reports.asset_id)' }
      when 'policy'
        { :conditions => 'foreman_openscap_arf_reports.id IN (
              SELECT MAX(id) FROM foreman_openscap_arf_reports sub
              WHERE sub.policy_id = foreman_openscap_arf_reports.policy_id)' }
      else
        fail "Cannot search last by #{by}"
      end
    end

    def assign_locations_organizations
      if foreman_host
        self.location_ids = [foreman_host.location_id] if SETTINGS[:locations_enabled]
        self.organization_ids = [foreman_host.organization_id] if SETTINGS[:organizations_enabled]
      end

      if katello_system
        self.locations = Location.where(:name => katello_system.location) if SETTINGS[:locations_enabled]
        self.organizations = [katello_system.organization] if SETTINGS[:organizations_enabled]
      end
    end

    def failed?
      failed > 0
    end

    def passed?
      passed > 0 && !failed?
    end

    def equal?(other)
      results = [xccdf_rule_results, other.xccdf_rule_results].flatten.group_by(&:xccdf_rule_id).values
      # for each rule, there should be one result from both reports
      return false unless results.map(&:length).all? { |item| item == 2 }
      results.map { |result| result.first.xccdf_result_id == result.last.xccdf_result_id }.all? && asset_id == other.asset_id && policy_id == other.policy_id
    end
  end
end
