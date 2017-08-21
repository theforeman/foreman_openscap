class RenameMailNotification < ActiveRecord::Migration
  def up
    notification = MailNotification.where(:name => 'openscap_policy_summary').first
    if notification
      notification.update_attribute :name, 'compliance_policy_summary'
    end
  end

  def down
    notification = MailNotification.where(:name => 'compliance_policy_summary').first
    if notification
      notification.update_attribute :name, 'openscap_policy_summary'
    end
  end
end
