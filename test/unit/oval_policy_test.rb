require 'test_plugin_helper'

class OvalPolicyTest < ActiveSupport::TestCase
  test "should not create OVAL policy with custom period" do
    policy = ForemanOpenscap::OvalPolicy.new(:name => "custom_policy",
                                             :period => 'custom',
                                             :cron_line => 'aaa')
    refute policy.save
    assert policy.errors[:cron_line].include?("does not consist of 5 parts separated by space")
  end

  test "should create OVAL policy with weekly period" do
    policy = ForemanOpenscap::OvalPolicy.new(:name => "custom_policy",
                                             :period => 'weekly',
                                             :weekday => 'monday')
    assert policy.save
  end

  test "should not create OVAL policy with weekly period" do
    policy = ForemanOpenscap::OvalPolicy.new(:name => "custom_policy",
                                             :period => 'weekly',
                                             :weekday => 'someday')
    refute policy.save
    assert policy.errors[:weekday].include?("is not a valid value")
  end

  test "should create OVAL policy with monthly period" do
    policy = ForemanOpenscap::OvalPolicy.new(:name => "custom_policy",
                                             :period => 'monthly',
                                             :day_of_month => '1')
    assert policy.save
  end

  test "should not create OVAL policy with monthly period" do
    policy = ForemanOpenscap::OvalPolicy.new(:name => "custom_policy",
                                             :period => 'monthly',
                                             :day_of_month => '0')
    refute policy.save
    assert policy.errors[:day_of_month].include?("must be between 1 and 31")
  end

  test "should not create OVAL policy when attributes do not correspond to selected period in new record" do
    policy_0 = ForemanOpenscap::OvalPolicy.new(:name => "custom_policy",
                                               :period => 'monthly',
                                               :weekday => 'tuesday',
                                               :cron_line => "0 0 0 0 0")
    policy_1 = ForemanOpenscap::OvalPolicy.new(:name => "test policy",
                                               :period => 'custom',
                                               :weekday => 'tuesday',
                                               :day_of_month => "15")
    refute policy_0.save
    refute policy_1.save
  end

  test "should update OVAL policy period" do
    policy = ForemanOpenscap::OvalPolicy.new(:name => "custom_policy",
                                             :period => 'monthly',
                                             :day_of_month => '5')
    assert policy.save
    policy.period = 'weekly'
    policy.weekday = 'monday'
    policy.day_of_month = nil
    assert policy.save
  end

  test "should add and remove hosts for OVAL policy" do
    host = FactoryBot.create(:oval_host)
    policy = ForemanOpenscap::OvalPolicy.new(:name => "custom_policy",
                                             :period => 'monthly',
                                             :day_of_month => '5',
                                             :host_ids => [host.id])

    assert policy.save
    assert policy.reload.hosts.include?(host)

    policy.host_ids = []
    assert policy.save
    refute policy.reload.hosts.include?(host)
  end

  test "should add and remove hostgroups for OVAL policy" do
    hostgroup = FactoryBot.create(:hostgroup)
    policy = ForemanOpenscap::OvalPolicy.new(:name => "custom_policy",
                                             :period => 'monthly',
                                             :day_of_month => '5',
                                             :hostgroup_ids => [hostgroup.id])
    assert policy.save
    assert policy.reload.hostgroups.include?(hostgroup)

    policy.hostgroup_ids = []
    assert policy.save
    refute policy.reload.hostgroups.include?(hostgroup)
  end

  test "should add and remove inherited OVAL policy" do
    hostgroup = FactoryBot.create(:hostgroup)
    host = FactoryBot.create(:oval_host, :hostgroup => hostgroup)
    policy_1 = ForemanOpenscap::OvalPolicy.new(:name => "custom_policy",
                                               :period => 'monthly',
                                               :day_of_month => '5',
                                               :hostgroup_ids => [hostgroup.id])
    policy_2 = ForemanOpenscap::OvalPolicy.new(:name => "custom_policy_again",
                                               :period => 'monthly',
                                               :day_of_month => '6',
                                               :host_ids => [host.id])
    assert policy_1.save
    assert policy_2.save

    assert host.reload.combined_oval_policies.include?(policy_1)
    assert host.combined_oval_policies.include?(policy_2)

    policy_1.hostgroup_ids = []
    assert policy_1.save
    refute host.reload.combined_oval_policies.include?(policy_1)
    assert host.combined_oval_policies.include?(policy_2)
  end
end
