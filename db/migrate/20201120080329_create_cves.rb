class CreateCves < ActiveRecord::Migration[6.0]
  def change
    create_table :foreman_openscap_cves do |t|
      t.string :ref_id, :null => false, :unique => true
      t.string :ref_url, :null => false, :unique => true
    end

    create_table :foreman_openscap_host_cves do |t|
      t.references :host, :null => false
      t.references :cve, :null => false
    end
  end
end
