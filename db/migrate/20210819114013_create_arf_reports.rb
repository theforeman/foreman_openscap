class CreateArfReports < ActiveRecord::Migration[6.0]
    def change
      create_table :foreman_openscap_arf_reports do |t|
        t.integer :host_id, null: false
        t.datetime :reported_at, null: false
        t.bigint :status
        t.text :metrics
        t.text :body
        t.string :digest, limit: 64
        t.integer :openscap_proxy_id

        t.index :host_id
        t.index :reported_at
      end
    end
  end