module Scaptimony::ReportDashboard
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
      (::Scaptimony::ArfReportBreakdown.sum(:passed)).to_f
    end

    def failed_breakdowns
      (::Scaptimony::ArfReportBreakdown.sum(:failed)).to_f
    end

    def othered_breakdowns
      (::Scaptimony::ArfReportBreakdown.sum(:othered)).to_f
    end
  end
end
