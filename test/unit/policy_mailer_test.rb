require 'test_plugin_helper'

class PolicyMailerTest < ActiveSupport::TestCase
  setup do
    @user = User.current = users :admin

    FactoryGirl.create(:mail_notification,
                       :name => :openscap_policy_summary,
                       :description => N_('A summary of reports for OpenScap policies'),
                       :mailer => 'ForemanOpenscap::PolicyMailer',
                       :method => 'policy_summary',
                       :subscription_type => 'report',
    )

    @user.mail_notifications << MailNotification[:openscap_policy_summary]

    ActionMailer::Base.deliveries = []
    @user.user_mail_notifications.first.deliver
    @email = ActionMailer::Base.deliveries.first
  end

  test 'policy mailer should deliver summary' do
    assert @email.to.include?("admin@someware.com")
  end

  test 'policy mailer should contain body' do
    refute @email.body.nil?
  end

  test 'policy mailer should have a correct subject' do
    refute @email.subject.empty?
    assert @email.subject.include? Setting[:email_subject_prefix]
  end

  test 'policy mailer sends Foreman URL in body' do
    assert @email.body.include? Setting[:foreman_url]
  end
end
