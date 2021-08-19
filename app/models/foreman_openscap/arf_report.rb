require 'foreman_openscap/helper'

module ForemanOpenscap
  class ArfReport < ApplicationRecord
    LOG_LEVELS = %w[debug info notice warning err alert emerg crit]
    include ::Foreman::Controller::AvoidLoneTaxonomies
    include ::Authorizable
    include ConfigurationStatusScopedSearch
    include ::Host::Hostmix
    include ::Taxonomix
    include OpenscapProxyExtensions

    # attr_accessible :host_id, :reported_at, :status, :metrics
    METRIC = %w[passed othered failed].freeze
    BIT_NUM = 10
    MAX = (1 << BIT_NUM) - 1

    include ComplianceStatusScopedSearch
  
    validates_lengths_from_database
    belongs_to_host
    has_one :hostgroup, :through => :host
  
    has_one :organization, :through => :host
    has_one :location, :through => :host
  
    validates :host_id, :status, :presence => true
    validates :reported_at, :presence => true

    scoped_search :relation => :host,         :on => :name,  :complete_value => true, :rename => :host
    scoped_search :relation => :organization, :on => :name,  :complete_value => true, :rename => :organization
    scoped_search :relation => :location,     :on => :name,  :complete_value => true, :rename => :location
    scoped_search :relation => :messages,     :on => :value,                          :rename => :log, :only_explicit => true
    scoped_search :relation => :sources,      :on => :value,                          :rename => :resource, :only_explicit => true
    scoped_search :relation => :hostgroup,    :on => :name,  :complete_value => true, :rename => :hostgroup
    scoped_search :relation => :hostgroup,    :on => :title, :complete_value => true, :rename => :hostgroup_fullname
    scoped_search :relation => :hostgroup,    :on => :title, :complete_value => true, :rename => :hostgroup_title

    scoped_search :on => :reported_at, :complete_value => true, :default_order => :desc, :rename => :reported, :only_explicit => true, :aliases => [:last_report]
    scoped_search :on => :host_id,     :complete_value => false, :only_explicit => true
    scoped_search :on => :origin

    scoped_search :on => :status, :offset => 0, :word_size => 4 * BIT_NUM, :complete_value => { :true => true, :false => false }, :rename => :eventful

    has_one :policy_arf_report
    has_one :policy, :through => :policy_arf_report, :dependent => :destroy
    has_one :asset, :through => :host, :class_name => 'ForemanOpenscap::Asset', :as => :assetable
    has_one :log, :foreign_key => :report_id
    belongs_to :openscap_proxy, :class_name => "SmartProxy"

    after_save :assign_locations_organizations
    before_destroy :destroy_from_proxy

    delegate :asset=, :to => :host

    default_scope do
      with_taxonomy_scope do
        order("#{self.table_name}.reported_at DESC")
      end
    end

    scope :hosts, lambda { includes(:policy) }
    scope :of_policy, lambda { |policy_id| joins(:policy_arf_report).merge(PolicyArfReport.of_policy(policy_id)) }

    scope :latest, -> {
      joins('INNER JOIN (SELECT host_id, policy_id, max(foreman_openscap_arf_reports.id) AS id
                         FROM foreman_openscap_arf_reports INNER JOIN foreman_openscap_policy_arf_reports
                             ON foreman_openscap_arf_reports.id = foreman_openscap_policy_arf_reports.arf_report_id
                         GROUP BY host_id, policy_id) latest
             ON foreman_openscap_arf_reports.id = latest.id')
    }

    scope :latest_of_policy, lambda { |policy|
      joins("INNER JOIN (SELECT host_id, policy_id, max(foreman_openscap_arf_reports.id) AS id
                         FROM foreman_openscap_arf_reports INNER JOIN foreman_openscap_policy_arf_reports
                            ON foreman_openscap_arf_reports.id = foreman_openscap_policy_arf_reports.arf_report_id
                         WHERE policy_id = #{policy.id}
                         GROUP BY host_id, policy_id) latest
             ON foreman_openscap_arf_reports.id = latest.id")
    }

    # TODO drop bit calculator and replace with columns
    scope :failed, lambda { where("(#{report_status_column} >> #{bit_mask 'failed'}) > 0") }
    scope :not_failed, lambda { where("(#{report_status_column} >> #{bit_mask 'failed'}) = 0") }
    scope :othered, lambda { where("(#{report_status_column} >> #{bit_mask 'othered'}) > 0").merge(not_failed) }
    scope :not_othered, lambda { where("(#{report_status_column} >> #{bit_mask 'othered'}) = 0") }
    scope :passed, lambda { where("(#{report_status_column} >> #{bit_mask 'passed'}) > 0").merge(not_failed).merge(not_othered) }

    # this is a tablescan and must be used in combination with reported_at (clause or order by) and limit
    scope :by_rule_result, lambda { |rule_name, rule_result| where("body LIKE ?", "%\"#{rule_name}\",\"#{rule_result}\"%") }

    # copy from ::Reports
    # returns reports for hosts in the User's filter set
    scope :my_reports, lambda {
      if !User.current.admin? || Organization.expand(Organization.current).present? || Location.expand(Location.current).present?
        joins_authorized(Host, :view_hosts)
      end
    }

    # returns recent reports
    scope :recent, ->(*args) { where("reported_at > ?", (args.first || 1.day.ago)).order(:reported_at) }

    # with_changes
    scope :interesting, -> { where("status <> 0") }

    # extracts serialized metrics and keep them as a hash_with_indifferent_access
    def metrics
      return {} if self[:metrics].nil?
      YAML.load(read_metrics).with_indifferent_access
    end

    # serialize metrics as YAML
    def metrics=(m)
      self[:metrics] = m.to_h.to_yaml unless m.nil?
    end

    def to_label
      "#{host.name} / #{reported_at}"
    end

    # add sort by report time
    def <=>(other)
      reported_at <=> other.reported_at
    end

    def created_at
      reported_at
    end

    # Expire reports based on time and status
    # Defaults to expire reports older than a week regardless of the status
    # This method will IS very slow, use only from rake task.
    # TODO this needs to be rewritten completely
    def self.expire(conditions, batch_size, sleep_time)
      timerange = conditions[:timerange] || 1.week
      status = conditions[:status]
      created = (Time.now.utc - timerange).to_formatted_s(:db)
      logger.info "Starting #{to_s.underscore.humanize.pluralize} expiration before #{created} status #{status || 'not set'} batch size #{batch_size} sleep #{sleep_time}"
      cond = "reported_at < \'#{created}\'"
      cond += " and status = #{status}" unless status.nil?
      total_count = 0
      report_ids = []
      start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      loop do
        Report.transaction do
          batch_start_time = Process.clock_gettime(Process::CLOCK_MONOTONIC)
          report_ids = where(cond).reorder('').limit(batch_size).pluck(:id)
          if report_ids.count > 0
            log_count = Log.unscoped.where(:report_id => report_ids).reorder('').delete_all
            count = where(:id => report_ids).reorder('').delete_all
            total_count += count
            rate = (count / (Process.clock_gettime(Process::CLOCK_MONOTONIC) - batch_start_time)).to_i
            Foreman::Logging.with_fields(expired_logs: log_count, expired_total: count, expire_rate: rate) do
              logger.info "Expired #{count} reports and #{log_count} logs at rate #{rate} reports/sec"
            end
          end
        end
        # Delete orphan messages/sources when no reports are left
        if report_ids.blank?
          message_count = Message.unscoped.where.not(id: Log.unscoped.distinct.select('message_id')).delete_all
          source_count = Source.unscoped.where.not(id: Log.unscoped.distinct.select('source_id')).delete_all
          Foreman::Logging.with_fields(deleted_messages: message_count, expired_sources: source_count) do
            logger.info "Expired #{message_count} messages and #{source_count} sources"
          end
          break
        end
        sleep sleep_time
      end
      duration = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start_time) / 60).to_i
      logger.info "Total expired reports #{total_count} in #{duration} min(s)"
      total_count
    end
  
    # represent if we have a report --> used to ensure consistency across host report state the report itself
    def no_report
      false
    end
  
    def self.origins
      Foreman::Plugin.report_origin_registry.all_origins
    end
  
    # TODO: remove metrics, remove status, create columns for these
    def read_metrics
      yml_hash = '!ruby/hash:ActiveSupport::HashWithIndifferentAccess'
      yml_params = /!ruby\/[\w-]+:ActionController::Parameters/
  
      metrics_attr = self[:metrics]
      metrics_attr.gsub!(yml_params, yml_hash)
      metrics_attr
    end
    # /copy from ::Reports

    def self.bit_mask(status)
      ComplianceStatus.bit_mask(status)
    end

    def self.report_status_column
      "status"
    end

    def status=(st)
      s = case st
          when Integer
            st
          when Hash, ActionController::Parameters
            ArfReportStatusCalculator.new(:counters => st).calculate
          else
            raise "Unsupported report status format #{st.class}"
          end
      write_attribute(:status, s)
    end

    delegate :status, :status_of, :to => :calculator
    delegate(*METRIC, :to => :calculator)

    def calculator
      ArfReportStatusCalculator.new(:bit_field => read_attribute(self.class.report_status_column))
    end

    def passed
      status_of "passed"
    end

    def failed
      status_of "failed"
    end

    def othered
      status_of "othered"
    end

    def rules_count
      status.values.sum
    end

    # calculate result digest (64 bytes)
    # TODO: if sources are already sorted from proxy this quicksort will be very fast
    def self.calculate_digest(body)
      body.sort_by!{|rec| rec[0]}
      digest = Digest::SHA2.new
      body.each do |rule_ident, result, _id|
        digest.update(rule_ident)
        digest.update(result)
      end
      digest.hexdigest
    end

    def self.create_arf(asset, proxy, params)
      arf_report = nil
      policy = Policy.find_by :id => params[:policy_id]
      return unless policy

      ArfReport.transaction do
        # construct body
        body = []
        if params[:logs]
          params[:logs].each do |log|
            rule_id, needs_update = Rule.where(label: log[:source]).pluck(:id, :needs_update)&.first
            if rule_id.nil? || needs_update
              new_rule = Rule.create!(label: log[:source],
                title: log[:title],
                severity: log[:severity],
                description: log[:description],
                references: log[:references]&.to_json,
                rationale: log[:rationale],
                fixes: log[:fixes]&.to_json,
                needs_update: false)
              rule_id = new_rule.id
            end
            body << [log[:source]&.to_s, log[:result]&.to_s, rule_id]
          end
        end
        # create report
        arf_report = ArfReport.create(:host => asset.host,
                                      :reported_at => Time.at(params[:date].to_i),
                                      :status => params[:metrics],
                                      :metrics => params[:metrics],
                                      :openscap_proxy => proxy,
                                      :body => body.to_json,
                                      :digest => self.calculate_digest(body))
        return arf_report unless arf_report.persisted?
        PolicyArfReport.where(:arf_report_id => arf_report.id, :policy_id => policy.id, :digest => params[:digest]).first_or_create!
      end
      arf_report
    end

    # returns array of result, message, resource, severity, description, rationale, references, fixes
    def body_as_table
      body_array = []
      return body_array if body.nil?
      JSON.parse(body).each do |rule_ident, result, rule_id|
        rule = Rule.find_by(id: rule_id)
        body_array << [result,
          rule&.title || '',
          rule_ident,
          rule&.severity || '',
          rule&.description || '',
          rule&.rationale || '',
          JSON.parse(rule&.references || '[]'),
          JSON.parse(rule&.fixes || '[]')]
      end
      body_array
    end

    def assign_locations_organizations
      if host
        self.location_ids = [host.location_id]
        self.organization_ids = [host.organization_id]
      end
    end

    def failed?
      failed > 0
    end

    def passed?
      passed > 0 && failed == 0 && othered == 0
    end

    def othered?
      !passed? && !failed?
    end

    def to_html
      openscap_proxy_api.arf_report_html(self, ForemanOpenscap::Helper::find_name_or_uuid_by_host(host))
    end

    def to_bzip
      openscap_proxy_api.arf_report_bzip(self, ForemanOpenscap::Helper::find_name_or_uuid_by_host(host))
    end

      def equal?(other)
      digest == other.digest &&
        host_id == other.host_id &&
        policy.id == other.policy.id
    end

    def destroy_from_proxy
      if !host
        destroy_from_proxy_warning "host"
      elsif !policy
        destroy_from_proxy_warning "policy"
      elsif !openscap_proxy
        destroy_from_proxy_warning "OpenSCAP proxy"
      else
        openscap_proxy_api.destroy_report(self, ForemanOpenscap::Helper::find_name_or_uuid_by_host(host))
      end
    end

    def destroy_from_proxy_warning(associated)
      logger.warn "Skipping deletion of report with id #{id} from proxy, no #{associated} associated with report"
      true
    end

    def self.newline_to_space(string)
      string.gsub(/ *\n+/, " ")
    end

    def self.references_links(references)
      return if references.nil?
      html_links = []
      references.each do |reference|
        next if reference['title'] == 'test_attestation' # A blank url created by OpenSCAP
        reference['html_link'] = "<a href='#{reference['href']}'>#{reference['href']}</a>" if reference['title'].blank?
        html_links << reference['html_link']
      end
      html_links.join(', ')
    end
  end
end
