class AddOvalPolicyReferenceToCve < ActiveRecord::Migration[6.0]
  def change
    add_column :foreman_openscap_host_cves, :oval_policy_id, :integer, :references => :oval_policy

    add_index :foreman_openscap_host_cves, [:host_id, :oval_policy_id, :cve_id], :unique => true, :name => :index_oval_policy_host_cve_id_on_host_cve
  end
end
