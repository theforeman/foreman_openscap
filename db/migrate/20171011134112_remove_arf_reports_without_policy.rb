class RemoveArfReportsWithoutPolicy < ActiveRecord::Migration
  def up
    User.as_anonymous_admin do
      ids_to_keep = ForemanOpenscap::ArfReport.unscoped.all.joins(:policy_arf_report).pluck(:id)
      ForemanOpenscap::ArfReport.unscoped.where.not(:id => ids_to_keep).find_in_batches do |batch|
        batch.map(&:destroy!)
      end
    end
  end
end
