class RemoveArfReportsWithoutPolicy < ActiveRecord::Migration
  def up
    if User.unscoped.find_by(:login => User::ANONYMOUS_ADMIN)
      User.as_anonymous_admin do
        delete_reports
      end
    else
      delete_reports
    end
  end

  def delete_reports
    ids_to_keep = ForemanOpenscap::ArfReport.unscoped.all.joins(:policy_arf_report).pluck(:id)
    ForemanOpenscap::ArfReport.unscoped.where.not(:id => ids_to_keep).find_in_batches do |batch|
      batch.map(&:destroy!)
    end
  end
end
