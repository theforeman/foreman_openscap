class CreateScaptimonyArfReportRaws < ActiveRecord::Migration
  def change
    create_table :scaptimony_arf_report_raws, :id => false do |t|
      t.references :arf_report, :index => true, :null => false
      t.integer :size
      t.binary :raw
    end
    add_index :scaptimony_arf_report_raws, [:arf_report_id], :unique => true
  end
end
