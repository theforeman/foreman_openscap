module ForemanOpenscap
  class ComplianceStatusResetter
    def self.to_inconclusive(host_ids)
      host_ids = Array(host_ids).compact.uniq
      return if host_ids.empty?

      now = Time.current
      rows = host_ids.map do |host_id|
        {
          :host_id => host_id,
          :type => ComplianceStatus.to_s,
          :status => ComplianceStatus::INCONCLUSIVE,
          :reported_at => now
        }
      end

      ComplianceStatus.upsert_all(rows, :unique_by => %i[type host_id], :update_only => %i[status reported_at])
    end
  end
end
