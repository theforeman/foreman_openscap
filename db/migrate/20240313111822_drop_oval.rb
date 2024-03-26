class DropOval < ActiveRecord::Migration[6.1]
  def up
    drop_table :foreman_openscap_host_cves
    drop_table :foreman_openscap_oval_contents
    drop_table :foreman_openscap_oval_policies
    drop_table :foreman_openscap_hostgroup_oval_facet_oval_policies
    drop_table :foreman_openscap_hostgroup_oval_facets
    drop_table :foreman_openscap_oval_facet_oval_policies
    drop_table :foreman_openscap_oval_facets
    drop_table :foreman_openscap_cves

    scope = ::HostStatus::Status.where(type: 'ForemanOpenscap::OvalStatus')
    host_ids = scope.pluck(:host_id)
    scope.delete_all
    ::Host::Managed.where(id: host_ids).find_each(&:refresh_global_status!)
  end
end
