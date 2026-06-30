module ForemanOpenscap
  class ComplianceStatus < ::HostStatus::Status
    COMPLIANT = 0
    INCONCLUSIVE = 1
    INCOMPLIANT = 2

    def self.status_name
      N_('Compliance')
    end

    def status_link
      host.arf_reports_path(:search => "host = #{host.name}")
    end

    def self.bit_mask(status)
      "#{ArfReport::BIT_NUM * ArfReport::METRIC.index(status)} & #{ArfReport::MAX}"
    end

    def to_label(_options = {})
      case status
      when COMPLIANT
        N_('Compliant')
      when INCONCLUSIVE
        N_('Inconclusive')
      when INCOMPLIANT
        N_('Incompliant')
      else
        N_('Unknown Compliance status')
      end
    end

    def to_global(_options = {})
      case status
      when COMPLIANT
        ::HostStatus::Global::OK
      when INCONCLUSIVE
        ::HostStatus::Global::WARN
      else
        ::HostStatus::Global::ERROR
      end
    end

    def relevant?(_options = {})
      # May fail host status during migration
      return false unless ForemanOpenscap::Asset.table_exists?
      host.policies.any? || host_has_hostgroup_policies?
    end

    def to_status(_options = {})
      latest_reports = host.combined_policies.flat_map { |p| host.last_report_for_policy p }
      return INCOMPLIANT if latest_reports.any?(&:failed?)
      return INCONCLUSIVE if latest_reports.any?(&:othered?)
      COMPLIANT
    end

    private

    def host_has_hostgroup_policies?
      return false if host.hostgroup_id.blank?

      ids = [host.hostgroup_id] + host.hostgroup.ancestor_ids
      ForemanOpenscap::Policy.joins(:assets)
                             .where('foreman_openscap_assets.assetable_type' => 'Hostgroup',
                                    'foreman_openscap_assets.assetable_id' => ids)
                             .exists?
    end
  end
end
