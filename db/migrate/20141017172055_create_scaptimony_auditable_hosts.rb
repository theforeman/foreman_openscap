class CreateScaptimonyAuditableHosts < ActiveRecord::Migration
  def change
    create_table :scaptimony_auditable_hosts, :id => false do |t|
      t.references :asset, :null => false
      t.references :host, :null => false
    end
    add_index :scaptimony_auditable_hosts, [:asset_id, :host_id], :unique => true
  end
end
