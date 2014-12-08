module Scaptimony::PolicyDashboard
  class Data
    attr_reader :report

    def initialize(policy, filter = "")
      @policy = policy
      @filter = filter
      @report = {}
      fetch_data
    end

    private
    attr_writer :report

    def fetch_data
      report.update(
        {:compliant_hosts => 3,
         :incompliant_hosts => 4,
         :report_delayed => 5,
         :report_missing => 6,
         :unassigned_hosts => 12,
        })
    end
  end
end
