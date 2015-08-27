module ForemanOpenscap::PolicyDashboard
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
        {:compliant_hosts => @policy.assets.hosts.comply_with(@policy).count,
         :incompliant_hosts => @policy.assets.hosts.incomply_with(@policy).count,
         :inconclusive_hosts => @policy.assets.hosts.inconclusive_with(@policy).count,
         :report_missing => @policy.assets.hosts.policy_reports_missing(@policy).count,
         :assigned_hosts => @policy.assets.hosts.count,
         :unassigned_hosts => hosts.count - @policy.assets.hosts.count
        })
    end
  end
end
