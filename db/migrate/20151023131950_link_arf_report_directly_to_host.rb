class LinkArfReportDirectlyToHost < ActiveRecord::Migration
  def up
    ForemanOpenscap::ArfReport.all.each do |report|
      asset = ForemanOpenscap::Asset.where(:id => report.host_id).first
      report.host_id = asset.host.id
      report.save!
    end
  end

  def down
    ForemanOpenscap::ArfReport.all.each do |report|
      asset = ForemanOpenscap::Asset.where(:assetable_id => report.host_id, :assetable_type => 'Host::Base').first
      report.host_id = asset.id
      report.save!
    end
  end
end
