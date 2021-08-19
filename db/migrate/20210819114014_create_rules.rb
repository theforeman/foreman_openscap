class CreateRules < ActiveRecord::Migration[6.0]
    def change
      create_table :foreman_openscap_rules do |t|
        t.text :label, null: false
        t.text :title
        t.string :severity
        t.text :description
        t.text :rationale
        t.text :references
        t.text :fixes
        t.boolean :needs_update, default: false

        t.index :label, using: :hash
      end
    end
  end