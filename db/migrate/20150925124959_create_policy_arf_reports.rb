class CreatePolicyArfReports < ActiveRecord::Migration
  def up
    create_table :foreman_openscap_policy_arf_reports do |t|
      t.integer :policy_id
      t.integer :arf_report_id
      t.string :digest, :limit => 128
    end
  end

  def down
    drop_table :foreman_openscap_policy_arf_reports
  end
end
