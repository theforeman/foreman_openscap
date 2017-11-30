class AddArfReportUniqueConstraint < ActiveRecord::Migration[4.2]
  def change
    add_index :scaptimony_arf_reports, %i[asset_id policy_id date digest],
              :unique => true, :name => :index_scaptimony_arf_reports_unique_set
  end
end
