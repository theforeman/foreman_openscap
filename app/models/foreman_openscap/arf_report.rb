require 'foreman_openscap/helper'

module ForemanOpenscap
  class ArfReport < ::Report
    include Taxonomix
    include OpenscapProxyExtensions

    # attr_accessible :host_id, :reported_at, :status, :metrics
    RESULT = %w(pass fail error unknown notapplicable notchecked notselected informational fixed)
    METRIC = %w(passed othered failed)
    BIT_NUM = 10
    MAX = (1 << BIT_NUM) - 1

    scoped_search :on => :status, :offset => 0, :word_size => 4*BIT_NUM, :complete_value => {:true => true, :false => false}, :rename => :eventful

    has_one :policy_arf_report, :dependent => :destroy
    has_one :policy, :through => :policy_arf_report
    has_one :asset, :through => :host, :class_name => 'ForemanOpenscap::Asset', :as => :assetable
    after_save :assign_locations_organizations
    has_one :log, :foreign_key => :report_id

    delegate :result, :to => :log, :allow_nil => true
    validates :result, :inclusion => { :in => RESULT }

    delegate :asset=, :to => :host

    default_scope do
      with_taxonomy_scope do
        order("#{self.table_name}.created_at DESC")
      end
    end

    scope :hosts, lambda { includes(:policy) }
    scope :of_policy, lambda { |policy_id| joins(:policy_arf_report).merge(PolicyArfReport.of_policy(policy_id)) }

    scope :latest, -> {
       joins('INNER JOIN (SELECT host_id, policy_id, max(reports.id) AS id
                          FROM reports INNER JOIN foreman_openscap_policy_arf_reports
                              ON reports.id = foreman_openscap_policy_arf_reports.arf_report_id
                          GROUP BY host_id, policy_id) latest
              ON reports.id = latest.id') }

    scope :latest_of_policy, lambda { |policy|
      joins("INNER JOIN (SELECT host_id, policy_id, max(reports.id) AS id
                         FROM reports INNER JOIN foreman_openscap_policy_arf_reports
                            ON reports.id = foreman_openscap_policy_arf_reports.arf_report_id
                         WHERE policy_id = #{policy.id}
                         GROUP BY host_id, policy_id) latest
             ON reports.id = latest.id")
    }

    scope :failed, lambda { where("(#{report_status_column} >> #{bit_mask 'failed'}) > 0") }
    scope :not_failed, lambda { where("(#{report_status_column} >> #{bit_mask 'failed'}) = 0") }

    scope :othered, lambda { where("(#{report_status_column} >> #{bit_mask 'othered'}) > 0").merge(not_failed) }
    scope :not_othered, lambda { where("(#{report_status_column} >> #{bit_mask 'othered'}) = 0") }

    scope :passed, lambda { where("(#{report_status_column} >> #{bit_mask 'passed'}) > 0").merge(not_failed).merge(not_othered) }

    def self.bit_mask(status)
      ComplianceStatus.bit_mask(status)
    end

    def self.report_status_column
      "status"
    end

    def status=(st)
      s = case st
          when Integer, Fixnum
            st
          when Hash
            ArfReportStatusCalculator.new(:counters => st).calculate
          else
            fail Foreman::Exception(N_('Unsupported report status format'))
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

    def self.create_arf(asset, params)
      # fail if policy does not exist.
      arf_report = nil
      policy = Policy.find(params[:policy_id])
      ArfReport.transaction do
        # TODO:RAILS-4.0: This should become arf_report = ArfReport.find_or_create_by! ...
        arf_report = ArfReport.create!(:host => asset.host,
                                       :reported_at => Time.at(params[:date].to_i),
                                       :status => params[:metrics],
                                       :metrics => params[:metrics],
                                       :openscap_proxy => asset.host.openscap_proxy)
        PolicyArfReport.where(:arf_report_id => arf_report.id, :policy_id => policy.id, :digest => params[:digest]).first_or_create!
        if params[:logs]
          params[:logs].each do |log|
            src = Source.find_or_create(log[:source])
            digest = Digest::SHA1.hexdigest(log[:title])
            msg = Message.where(:value => N_(log[:title]), :digest => digest, :severity => log[:severity],
                                :description => newline_to_space(log[:description]), :rationale => newline_to_space(log[:rationale]),
                                :scap_references => references_links(log[:references])).first_or_create
            #TODO: log level
            Log.create!(:source_id => src.id,
                        :message_id => msg.id,
                        :level => :info,
                        :result => log[:result],
                        :report => arf_report)
          end
        end
      end
      arf_report
    end

    def assign_locations_organizations
      if host
        self.location_ids = [host.location_id] if SETTINGS[:locations_enabled]
        self.organization_ids = [host.organization_id] if SETTINGS[:organizations_enabled]
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
      results = [logs, other.logs].flatten.group_by(&:source_id).values
      # for each rule, there should be one result from both reports
      return false unless results.map(&:length).all? { |item| item == 2 }
      results.all? { |result| result.first.source_id == result.last.source_id } &&
        host_id == other.host_id &&
        policy.id == other.policy.id
    end

    def destroy
      if openscap_proxy_api.destroy_report(self, ForemanOpenscap::Helper::find_name_or_uuid_by_host(host))
        super
      else
        false
      end
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
