require 'test_plugin_helper'

class OpenscapHostTest < ActiveSupport::TestCase
  setup do
    disable_orchestration
    User.current = users :admin
    Setting[:token_duration] = 0
    Scaptimony::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
  end

  test 'Host has policy' do
    host = FactoryGirl.create(:host)
    assert_empty(host.policies)
    policy = FactoryGirl.create(:policy)

    assert(policy.assign_hosts([host]), 'Host policies should be assigned')
    assert_includes(host.policies, policy)
  end

  test 'Host has policies via its hostgroup' do
    host = FactoryGirl.create(:host, :with_hostgroup)
    hostgroup = host.hostgroup
    policy = FactoryGirl.create(:policy)
    assert(policy.hostgroup_ids = ["#{hostgroup.id}"])
    refute_empty(host.combined_policies)
    assert_includes(host.combined_policies, policy)
  end
end
