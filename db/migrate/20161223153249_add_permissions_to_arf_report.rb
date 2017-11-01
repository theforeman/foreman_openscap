class AddPermissionsToArfReport < ActiveRecord::Migration
  def up
    Permission.where(:name => %w[view_arf_reports destroy_arf_reports])
              .update_all(:resource_type => 'ForemanOpenscap::ArfReport')
  end

  def down
    Permission.where(:name => %w[view_arf_reports destroy_arf_reports])
              .update_all(:resource_type => '')
  end
end
