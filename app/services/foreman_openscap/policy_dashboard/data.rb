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
        { :compliant_hosts => Host::Managed.comply_with(@policy).count,
          :incompliant_hosts => Host::Managed.not_comply_with(@policy).count,
          :inconclusive_hosts => Host::Managed.inconclusive_with(@policy).count,
          :report_missing => Host::Managed.policy_reports_missing(@policy).count,
          :assigned_hosts => Host::Managed.assigned_to_policy(@policy).count,
          :unassigned_hosts => Host::Managed.removed_from_policy(@policy).count }
      )
    end
  end
end
