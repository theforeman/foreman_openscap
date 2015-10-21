module ForemanOpenscap::HostReportDashboard
  class Data
    attr_reader :report

    def initialize(policy_id, asset_id)
      @latest_report = ::ForemanOpenscap::ArfReport.where(:asset_id =>  asset_id, :policy_id => policy_id).order('created_at DESC').limit(1).first
      @report = {}
      fetch_data
    end

    def has_data?
      latest_report.present?
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
      has_data? ? @latest_report.passed : 0
    end

    def report_failed
      has_data? ? @latest_report.failed : 0
    end

    def report_othered
      has_data? ? @latest_report.othered : 0
    end

  end
end
