class DropUnusedTables < ActiveRecord::Migration[6.0]
  def up
    drop_table :foreman_openscap_arf_reports
    drop_table :foreman_openscap_arf_report_raws
  end
end
