module ForemanOpenscap
  class OvalStatus < ::HostStatus::Status
    PATCHED = 0
    VULNERABLE = 1
    PATCH_AVAILABLE = 2

    def self.status_name
      N_('OVAL scan')
    end

    def to_label(options = {})
      case to_status
      when PATCHED
        N_('No Vulnerabilities found')
      when VULNERABLE
        N_("%s vulnerabilities found") % host.cves_without_errata.count
      when PATCH_AVAILABLE
        N_("%s vulnerabilities with available patch found") % host.cves_with_errata.count
      else
        N_('Unknown OVAL status')
      end
    end

    def to_global(options = {})
      case to_status
      when PATCHED
        ::HostStatus::Global::OK
      when VULNERABLE
        ::HostStatus::Global::WARN
      when PATCH_AVAILABLE
        ::HostStatus::Global::ERROR
      end
    end

    def relevant?(options = {})
      host.combined_oval_policies.any?
    end

    def to_status(options = {})
      return PATCH_AVAILABLE if host.cves_with_errata.any?
      return VULNERABLE if host.cves_without_errata.any?
      PATCHED
    end
  end
end
