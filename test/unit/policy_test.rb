require 'test_plugin_helper'

class PolicyTest < ActiveSupport::TestCase
  setup do
    ForemanOpenscap::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
    ForemanOpenscap::DataStreamValidator.any_instance.stubs(:validate)
    ForemanOpenscap::ScapContent.any_instance.stubs(:fetch_profiles).returns({ 'test_profile_key' => 'test_profile_title' })
    @scap_content = FactoryBot.create(:scap_content)
    @scap_profile = FactoryBot.create(:scap_content_profile, :scap_content => @scap_content)
    @tailoring_profile = FactoryBot.create(:scap_content_profile, :profile_id => 'xccdf_org.test.tailoring_test_profile')
  end

  test "should assign hostgroups by their ids" do
    ForemanOpenscap::Policy.any_instance.stubs(:find_scap_puppetclass).returns(FactoryBot.create(:puppetclass, :name => 'foreman_scap_client'))
    ForemanOpenscap::Policy.any_instance.stubs(:populate_overrides)
    hg1 = FactoryBot.create(:hostgroup)
    hg2 = FactoryBot.create(:hostgroup)
    host = FactoryBot.create(:compliance_host)
    asset = FactoryBot.create(:asset, :assetable_id => hg1.id, :assetable_type => 'Hostgroup')
    host_asset = FactoryBot.create(:asset, :assetable_id => host.id, :assetable_type => 'Host::Base')
    policy = FactoryBot.create(:policy, :assets => [asset, host_asset], :scap_content => @scap_content, :scap_content_profile => @scap_profile)
    policy.hostgroup_ids = [hg1, hg2].map(&:id)
    policy.save!
    assert_equal 2, policy.hostgroups.count
    assert_equal 3, policy.assets.count
    assert_equal host, policy.hosts.first
  end

  test "should assign hosts by their ids" do
    ForemanOpenscap::Policy.any_instance.stubs(:find_scap_puppetclass).returns(FactoryBot.create(:puppetclass, :name => 'foreman_scap_client'))
    ForemanOpenscap::Policy.any_instance.stubs(:populate_overrides)
    host1 = FactoryBot.create(:compliance_host)
    host2 = FactoryBot.create(:compliance_host)
    hostgroup = FactoryBot.create(:hostgroup)
    asset = FactoryBot.create(:asset, :assetable_id => host1.id, :assetable_type => 'Host::Base')
    hostgroup_asset = FactoryBot.create(:asset, :assetable_id => hostgroup.id, :assetable_type => 'Hostgroup')
    policy = FactoryBot.create(:policy, :assets => [asset, hostgroup_asset], :scap_content => @scap_content, :scap_content_profile => @scap_profile)
    policy.host_ids = [host1, host2].map(&:id)
    policy.save!
    assert_equal 2, policy.hosts.count
    assert_equal 3, policy.assets.count
    assert_equal hostgroup, policy.hostgroups.first
  end

  test "should remove associated hostgroup" do
    ForemanOpenscap::Policy.any_instance.stubs(:find_scap_puppetclass).returns(FactoryBot.create(:puppetclass, :name => 'foreman_scap_client'))
    ForemanOpenscap::Policy.any_instance.stubs(:populate_overrides)
    hg = FactoryBot.create(:hostgroup)
    asset = FactoryBot.create(:asset, :assetable_id => hg.id, :assetable_type => 'Hostgroup')
    policy = FactoryBot.create(:policy, :assets => [asset], :scap_content => @scap_content, :scap_content_profile => @scap_profile)
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

  test "should create a policy with default SCAP content profile (profile id is nil)" do
    p = ForemanOpenscap::Policy.new(:name => "custom_policy",
                                    :scap_content_id => @scap_content.id,
                                    :period => 'monthly',
                                    :day_of_month => '5')
    assert p.save
  end

  test "should have correct scap profile in enc" do
    p = FactoryBot.create(:policy, :scap_content => @scap_content, :scap_content_profile => @scap_profile)
    profile_id = p.scap_content_profile.profile_id
    assert_equal profile_id, p.to_enc['profile_id']
    tailoring_profile = FactoryBot.create(:scap_content_profile, :profile_id => 'xccdf_org.test.tailoring_test_profile')
    p.tailoring_file_profile = tailoring_profile
    assert_equal tailoring_profile.profile_id, p.to_enc['profile_id']
  end

  test "should not create policy with incorrect tailoring profile" do
    tailoring_profile = FactoryBot.create(:scap_content_profile, :profile_id => 'xccdf_org.test.common_tailoring_profile')
    tailoring_file = FactoryBot.create(:tailoring_file, :scap_content_profiles => [tailoring_profile])
    p = ForemanOpenscap::Policy.create(:name => "custom_policy",
                                       :period => 'monthly',
                                       :day_of_month => '5',
                                       :scap_content => @scap_content,
                                       :scap_content_profile => @scap_profile,
                                       :tailoring_file => tailoring_file,
                                       :tailoring_file_profile => @scap_profile)
    refute p.valid?
    p.tailoring_file_profile = tailoring_profile
    assert p.save
  end

  test "should have digest in enc download path for scap content" do
    p = ForemanOpenscap::Policy.new(:name => "custom_policy",
                                    :scap_content_id => @scap_content.id,
                                    :scap_content_profile_id => @scap_profile.id,
                                    :period => 'monthly',
                                    :day_of_month => '5')
    assert_equal 6, p.to_enc['download_path'].split('/').length
    assert_equal @scap_content.digest, p.to_enc['download_path'].split('/').last
  end

  test "should have digest in enc download path for tailoring file" do
    tailoring_file = FactoryBot.create(:tailoring_file)
    p = ForemanOpenscap::Policy.new(:name => "custom_policy",
                                    :scap_content_id => @scap_content.id,
                                    :scap_content_profile_id => @scap_profile.id,
                                    :tailoring_file => tailoring_file,
                                    :tailoring_file_profile => @tailoring_profile,
                                    :period => 'monthly',
                                    :day_of_month => '5')
    assert_equal 6, p.to_enc['tailoring_download_path'].split('/').length
    assert_equal tailoring_file.digest, p.to_enc['tailoring_download_path'].split('/').last
  end

  test "should have assigned a content profile that belongs to assigned scap content" do
    scap_content_2 = FactoryBot.create(:scap_content)
    p = ForemanOpenscap::Policy.create(:name => "valid_profile_policy",
                                       :scap_content_id => @scap_content.id,
                                       :scap_content_profile_id => @scap_profile.id,
                                       :period => 'monthly',
                                       :day_of_month => '5')
    assert p.valid?
    q = ForemanOpenscap::Policy.create(:name => "invalid_profile_policy",
                                       :scap_content_id => scap_content_2.id,
                                       :scap_content_profile_id => @scap_profile.id,
                                       :period => 'monthly',
                                       :day_of_month => '5')
    refute q.valid?
    assert_equal "does not have the selected SCAP content profile", q.errors.messages[:scap_content_id].first
  end

  test "should delete arf_report when deleting policy" do
    policy = FactoryBot.create(:policy, :scap_content => @scap_content, :scap_content_profile => @scap_profile)
    host = FactoryBot.create(:compliance_host)
    arf_report = FactoryBot.create(:arf_report, :host_id => host.id)
    policy_arf_report = FactoryBot.create(:policy_arf_report, :policy_id => policy.id, :arf_report_id => arf_report.id)
    policy.destroy
    assert_empty ForemanOpenscap::PolicyArfReport.where(:id => policy_arf_report.id)
    assert_empty ForemanOpenscap::ArfReport.where(:id => arf_report.id)
  end
end
