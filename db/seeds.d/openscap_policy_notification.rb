N_('Compliance policy summary')

policy_notification = {
  :name => :compliance_policy_summary,
  :description => N_('A summary of reports for OpenSCAP policies'),
  :mailer => 'ForemanOpenscap::PolicyMailer',
  :method => 'policy_summary',
  :subscription_type => 'report',
}

MailNotification.where(policy_notification).first_or_create
