require 'test_plugin_helper'

class LookupKeyOverriderTest < ActiveSupport::TestCase
  setup do
    ForemanOpenscap::ScapContent.any_instance.stubs(:fetch_profiles).returns({ 'test_profile_key' => 'test_profile_title' })
    @scap_content = FactoryBot.create(:scap_content)
    @scap_profile = FactoryBot.create(:scap_content_profile, :scap_content => @scap_content)
  end

  test 'should override puppet class parameters' do
    skip unless puppet_available?
    server_param, port_param, policies_param = setup_puppet_class.values_at :server_param, :port_param, :policies_param
    refute server_param.override
    refute port_param.override
    refute policies_param.override
    policy = FactoryBot.create(:policy, :scap_content => @scap_content, :scap_content_profile => @scap_content_profile, :deploy_by => :puppet)
    ForemanOpenscap::LookupKeyOverrider.new(policy).override
    assert server_param.reload.override
    assert port_param.reload.override
    assert policies_param.reload.override
    assert_equal '<%= @host.policies_enc %>', policies_param.default_value
  end

  test 'should add error when no puppet class found' do
    skip unless puppet_available?
    puppet_class = ::ForemanPuppet::Puppetclass.find_by :name => ForemanOpenscap::ClientConfig::Puppet.new.puppetclass_name
    puppet_class.destroy if puppet_class
    policy = FactoryBot.create(:policy, :scap_content => @scap_content, :scap_content_profile => @scap_content_profile, :deploy_by => :puppet)
    ForemanOpenscap::LookupKeyOverrider.new(policy).override
    assert_equal ["Required Puppet class foreman_scap_client was not found, please ensure it is imported first."], policy.errors[:base]
  end

  test 'should add error when deployment type is not available' do
    ForemanOpenscap::ClientConfig::Ansible.any_instance.stubs(:available?).returns(false)
    policy = FactoryBot.build(:policy, :scap_content => @scap_content,
                                       :scap_content_profile => @scap_profile,
                                       :deploy_by => 'ansible')
    overrider = ForemanOpenscap::LookupKeyOverrider.new(policy)
    overrider.expects(:override_required_params).never
    overrider.override
    assert_equal "Ansible was selected to deploy policy to clients, but Ansible is not available. Are you missing a plugin?",
                 policy.errors[:deploy_by].first
  end

  test 'should add error when lookup keys not present' do
    skip unless puppet_available?
    server_param, port_param, policies_param = setup_puppet_class.values_at :server_param, :port_param, :policies_param
    server_param.destroy
    port_param.destroy
    policy = FactoryBot.create(:policy, :scap_content => @scap_content, :scap_content_profile => @scap_content_profile, :deploy_by => :puppet)
    ForemanOpenscap::LookupKeyOverrider.new(policy).override
    err = "The following Smart Class Parameters were missing for foreman_scap_client: port, server. Make sure they are imported before proceeding."
    assert_equal err, policy.errors[:base].first
  end
end
