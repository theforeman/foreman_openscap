class AddHasErrataToCve < ActiveRecord::Migration[6.0]
  def change
    add_column :foreman_openscap_cves, :has_errata, :boolean
    add_column :foreman_openscap_cves, :definition_id, :string, :null => false
    change_column :foreman_openscap_cves, :ref_id, :string, :null => false
    change_column :foreman_openscap_cves, :ref_url, :string, :null => false
  end
end
