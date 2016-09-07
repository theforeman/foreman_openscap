require 'test_plugin_helper'

class PolicyTest < ActiveSupport::TestCase
  setup do
    ForemanOpenscap::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
    @scap_content = FactoryGirl.create(:scap_content)
    @scap_profile = FactoryGirl.create(:scap_content_profile)
  end

  test "should assign hostgroups by their ids" do
    ForemanOpenscap::Policy.any_instance.stubs(:find_scap_puppetclass).returns(FactoryGirl.create(:puppetclass, :name => 'foreman_scap_client'))
    ForemanOpenscap::Policy.any_instance.stubs(:populate_overrides)
    hg1 = FactoryGirl.create(:hostgroup)
    hg2 = FactoryGirl.create(:hostgroup)
    asset = FactoryGirl.create(:asset, :assetable_id => hg1.id, :assetable_type => 'Hostgroup')
    policy = FactoryGirl.create(:policy, :assets => [asset])
    policy.hostgroup_ids = [hg1, hg2].map(&:id)
    policy.save!
    assert_equal 2, policy.hostgroups.count
    assert policy.hostgroups.include?(hg2)
  end

  test "should remove associated hostgroup" do
    ForemanOpenscap::Policy.any_instance.stubs(:find_scap_puppetclass).returns(FactoryGirl.create(:puppetclass, :name => 'foreman_scap_client'))
    ForemanOpenscap::Policy.any_instance.stubs(:populate_overrides)
    hg = FactoryGirl.create(:hostgroup)
    asset = FactoryGirl.create(:asset, :assetable_id => hg.id, :assetable_type => 'Hostgroup')
    policy = FactoryGirl.create(:policy, :assets => [asset])
    policy.save!
    hg.hostgroup_classes.destroy_all
    hg.destroy
    assert_equal 0, policy.hostgroups.count
  end

  test "should create policy with custom period" do
    p = ForemanOpenscap::Policy.new(:name => "custom_policy",
                                    :scap_content_id => @scap_content.id,
                                    :scap_content_profile_id => @scap_profile.id,
                                    :period => 'custom',
                                    :cron_line => '6 * 15 12 0')
    assert p.save
  end

  test "should not create policy with custom period" do
    p = ForemanOpenscap::Policy.new(:name => "custom_policy",
                                    :scap_content_id => @scap_content.id,
                                    :scap_content_profile_id => @scap_profile.id,
                                    :period => 'custom',
                                    :cron_line => 'aaa')
    refute p.save
    assert p.errors[:cron_line].include?("does not consist of 5 parts separated by space")
  end

  test "should create policy with weekly period" do
    p = ForemanOpenscap::Policy.new(:name => "custom_policy",
                                    :scap_content_id => @scap_content.id,
                                    :scap_content_profile_id => @scap_profile.id,
                                    :period => 'weekly',
                                    :weekday => 'monday')
    assert p.save
  end

  test "should not create policy with weekly period" do
    p = ForemanOpenscap::Policy.new(:name => "custom_policy",
                                    :scap_content_id => @scap_content.id,
                                    :scap_content_profile_id => @scap_profile.id,
                                    :period => 'weekly',
                                    :weekday => 'someday')
    refute p.save
    assert p.errors[:weekday].include?("is not a valid value")
  end

  test "should create policy with monthly period" do
    p = ForemanOpenscap::Policy.new(:name => "custom_policy",
                                    :scap_content_id => @scap_content.id,
                                    :scap_content_profile_id => @scap_profile.id,
                                    :period => 'monthly',
                                    :day_of_month => '1')
    assert p.save
  end

  test "should not create policy with monthly period" do
    p = ForemanOpenscap::Policy.new(:name => "custom_policy",
                                    :scap_content_id => @scap_content.id,
                                    :scap_content_profile_id => @scap_profile.id,
                                    :period => 'monthly',
                                    :day_of_month => '0')
    refute p.save
    assert p.errors[:day_of_month].include?("must be between 1 and 31")
  end

  test "should not create policy when attributes do not correspond to selected period in new record" do
    p = ForemanOpenscap::Policy.new(:name => "custom_policy",
                                    :scap_content_id => @scap_content.id,
                                    :scap_content_profile_id => @scap_profile.id,
                                    :period => 'monthly',
                                    :weekday => 'tuesday',
                                    :cron_line => "0 0 0 0 0")
    policy = ForemanOpenscap::Policy.new(:name => "test policy",
                                         :scap_content_id => @scap_content.id,
                                         :scap_content_profile_id => @scap_profile.id,
                                         :period => 'custom',
                                         :weekday => 'tuesday',
                                         :day_of_month => "15")
    refute p.save
    refute policy.save
    assert p.weekday.empty?
    assert p.cron_line.empty?
    assert policy.weekday.empty?
    assert policy.day_of_month.empty?
  end

  test "should update policy period" do
    p = ForemanOpenscap::Policy.new(:name => "custom_policy",
                                    :scap_content_id => @scap_content.id,
                                    :scap_content_profile_id => @scap_profile.id,
                                    :period => 'monthly',
                                    :day_of_month => '5')
    assert p.save
    p.period = 'weekly'
    p.weekday = 'monday'
    p.day_of_month = nil
    assert p.save
  end

  test "should not create policy without SCAP content" do
    p = ForemanOpenscap::Policy.new(:name => "custom_policy",
                                    :scap_content_profile_id => @scap_profile.id,
                                    :period => 'monthly',
                                    :day_of_month => '5')
    refute p.save
    assert p.errors[:scap_content_id].include?("can't be blank")
  end

  test "should not create policy without SCAP content profile" do
    p = ForemanOpenscap::Policy.new(:name => "custom_policy",
                                    :scap_content_id => @scap_content.id,
                                    :period => 'monthly',
                                    :day_of_month => '5')
    refute p.save
    assert p.errors[:scap_content_profile_id].include?("can't be blank")
  end
end
