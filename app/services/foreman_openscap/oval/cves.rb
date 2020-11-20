module ForemanOpenscap
  module Oval
    class Cves
      def create(host, cve_data)
        unique_cves = cve_data['oval_results'].filter { |data| data['result'] == 'true' }.flat_map { |data| data['references'] }.uniq

        cves_to_add = unique_cves.map { |ref| ::ForemanOpenscap::Cve.find_or_create_by(:ref_id => ref['ref_id'], :ref_url => ref['ref_url']) }

        cve_ids_to_check = host.cve_ids - cves_to_add.pluck(:id).compact
        host.cves = cves_to_add
        delete_orphaned_cves cve_ids_to_check if host.save
        host
      end

      private

      def delete_orphaned_cves(ids)
        associated_ids = ::ForemanOpenscap::HostCve.where(:cve_id => ids).select(:cve_id).distinct.pluck(:cve_id)
        ::ForemanOpenscap::Cve.where(:id => ids - associated_ids).destroy_all
      end
    end
  end
end
