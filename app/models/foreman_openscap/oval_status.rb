module ForemanOpenscap
  class OvalStatus < ::HostStatus::Status
    PATCHED = 0
    VULNERABLE = 1

    def self.status_name
      N_('OVAL')
    end

    def to_label(options = {})
      case to_status
      when PATCHED
        N_('Patched')
      when VULNERABLE
        N_('Vulnerable')
      else
        N_('Unknown OVAL status')
      end
    end

    def to_global(options = {})
      case to_status
      when PATCHED
        ::HostStatus::Global::OK
      when VULNERABLE
        ::HostStatus::Global::ERROR
      end
    end

    def relevant?(options = {})
      host.combined_oval_policies.any?
    end

    def to_status(options = {})
      host.cves.any? ? VULNERABLE : PATCHED
    end
  end
end
