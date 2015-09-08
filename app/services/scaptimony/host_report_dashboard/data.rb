module Scaptimony::HostReportDashboard
  class Data
    attr_reader :report

    def initialize(policy_id, asset_id)
      @latest_report = ::ForemanOpenscap::ArfReport.where(:asset_id =>  asset_id, :policy_id => policy_id).order('created_at DESC').limit(1).first
      @report = {}
      fetch_data
    end

    private
    attr_writer :report
    attr_accessor :latest_report

    def fetch_data
      report.update(
          {
            :passed  => report_passed,
            :failed  => report_failed,
            :othered => report_othered
          }
      )
    end

    def report_passed
      @latest_report.passed
    end

    def report_failed
      @latest_report.failed
    end

    def report_othered
      @latest_report.othered
    end

  end
end
