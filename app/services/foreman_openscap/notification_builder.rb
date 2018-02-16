module ForemanOpenscap
  class NotificationBuilder < ::UINotifications::RemoteExecutionJobs::BaseJobFinish
    def deliver!
      ::Notification.create!(
        :audience => Notification::AUDIENCE_USER,
        :notification_blueprint => blueprint,
        :initiator => initiator,
        :message => message,
        :subject => subject,
        :actions => {
          :links => links
        }
      )
    end

    def blueprint
      @blueprint ||= NotificationBlueprint.unscoped.find_by(:name => 'openscap_scan_succeeded')
    end

    def hosts_count
      @hosts_count ||= subject.template_invocations_hosts.size
    end

    def message
      UINotifications::StringParser.new(blueprint.message, { hosts_count: hosts_count })
    end

    def links
      job_links + scap_links
    end

    # TODO do this only if there's single host
    # TODO also add link to policies dashboards for a given host
    def scap_links
      UINotifications::URLResolver.new(
        subject.template_invocations_hosts.first,
        {
          :links => [{
                       :path_method => :host_path,
                       :title => _('Scanned Host')
                     }]
        }
      ).actions[:links]
    end

    def job_links
      UINotifications::URLResolver.new(
        subject,
        {
          :links => [{
                       :path_method => :job_invocation_path,
                       :title => _('Job Details')
                     }]
        }
      ).actions[:links]
    end
  end
end
