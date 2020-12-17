module ForemanOpenscap
  module Oval
    class Cves
      def create(host, cve_data)
        cves_to_add = cve_data['oval_results'].reduce([]) do |memo, data|
          next memo unless data['result'] == 'true'
          cves, errata = data['references'].partition { |ref| ref['ref_id'].start_with?('CVE') }

          cves.map do |cve|
            memo << ::ForemanOpenscap::Cve.find_or_create_by(
              :ref_id => cve['ref_id'],
              :ref_url => cve['ref_url'],
              :has_errata => !errata.empty?,
              :definition_id => data['definition_id']
            )
          end
          memo
        end

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
