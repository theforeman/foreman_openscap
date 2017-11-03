require 'test_plugin_helper'

class PolicyMailerTest < ActiveSupport::TestCase
  setup do
    @user = User.current = users :admin

    FactoryBot.create(:mail_notification,
                      :name => :openscap_policy_summary,
                      :description => N_('A summary of reports for OpenScap policies'),
                      :mailer => 'ForemanOpenscap::PolicyMailer',
                      :method => 'policy_summary',
                      :subscription_type => 'report',)
    # just to have some content to send
    ForemanOpenscap::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
    host = FactoryBot.create(:compliance_host)
    asset = FactoryBot.create(:asset, :assetable_id => host.id)
    policy = FactoryBot.create(:policy, :assets => [asset])
    arf_report = FactoryBot.create(:arf_report, :policy => policy, :host_id => host.id)
    policy_arf_report = FactoryBot.create(:policy_arf_report, :policy_id => policy.id, :arf_report_id => arf_report.id)

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
    assert @email.subject.include? Setting[:email_subject_prefix].first
  end

  test 'policy mailer sends Foreman URL in body' do
    assert @email.body.include? Setting[:foreman_url]
  end
end
