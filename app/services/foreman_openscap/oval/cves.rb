module ForemanOpenscap
  module Oval
    class Cves
      def create(host, cve_data)
        policy_id = cve_data['oval_policy_id']

        incoming_cves = cve_data['oval_results'].reduce([]) do |memo, data|
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

        current = ForemanOpenscap::Cve.of_oval_policy(policy_id).of_host(host.id)
        to_delete = current - incoming_cves
        to_create = incoming_cves - current

        ::ForemanOpenscap::HostCve.where(:host_id => host.id, :oval_policy_id => policy_id, :cve_id => to_delete.pluck(:id)).destroy_all
        host.host_cves.build(to_create.map { |cve| { :host_id => host.id, :oval_policy_id => policy_id, :cve_id => cve.id } })

        delete_orphaned_cves to_delete.pluck(:id) if host.save
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
