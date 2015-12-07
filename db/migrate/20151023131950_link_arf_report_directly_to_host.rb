class LinkArfReportDirectlyToHost < ActiveRecord::Migration
  def up
    ForemanOpenscap::ArfReport.find_in_batches do |batch|
      batch.each do |report|
        asset = ForemanOpenscap::Asset.find(:id => report.host_id)
        report.host_id = asset.host.id
        report.save!
      end
    end
  end

  def down
    ForemanOpenscap::ArfReport.find_in_batches do |batch|
      batch.all.each do |report|
        asset = ForemanOpenscap::Asset.find(:assetable_id => report.host_id, :assetable_type => 'Host::Base')
        report.host_id = asset.id
        report.save!
      end
    end
  end
end
