require 'test_plugin_helper'

class PolicyTest < ActiveSupport::TestCase
  setup do
    ForemanOpenscap::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
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
    hg1 = FactoryGirl.create(:hostgroup)
    asset = FactoryGirl.create(:asset, :assetable_id => hg1.id, :assetable_type => 'Hostgroup')
    policy = FactoryGirl.create(:policy, :assets => [asset])
    policy.hostgroup_ids = [hg1].map(&:id)
    policy.save!
    hg1.destroy
    assert_equal 0, policy.hostgroups.count
  end
end
