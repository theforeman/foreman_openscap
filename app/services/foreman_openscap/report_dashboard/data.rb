module ForemanOpenscap::ReportDashboard
  class Data
    attr_reader :report

    def initialize(filter = "")
      @filter = filter
      @report = {}
      fetch_data
    end

    private
    attr_writer :report
    attr_accessor :filter

    def fetch_data
      report.update(
        {
          :passed  => passed_breakdowns,
          :failed  => failed_breakdowns,
          :othered => othered_breakdowns
        }
      )
    end

    def passed_breakdowns
      Log.where(:result => 'pass').joins("INNER JOIN reports ON reports.id = report_id").count(:id).to_f
    end

    def failed_breakdowns
      Log.where(:result => 'fail').joins("INNER JOIN reports ON reports.id = report_id").count(:id).to_f
    end

    def othered_breakdowns
      Log.where(:result => ForemanOpenscap::ArfReport::RESULT[2..-1]).joins("INNER JOIN reports ON reports.id = report_id").count(:id).to_f
    end
  end
end
