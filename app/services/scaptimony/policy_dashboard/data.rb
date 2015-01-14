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

    def hosts
      @hosts ||= Host.authorized(:view_hosts, Host)
    end

    def fetch_data
      report.update(
        {:compliant_hosts => @policy.assets.comply_with(@policy).count,
         :incompliant_hosts => @policy.assets.incomply_with(@policy).count,
         :inconclusive_hosts => @policy.assets.inconclusive_with(@policy).count,
         :report_missing => @policy.assets.policy_reports_missing(@policy).count,
         :assigned_hosts => @policy.assets.count,
         :unassigned_hosts => hosts.count - @policy.hosts.count
        })
    end
  end
end
