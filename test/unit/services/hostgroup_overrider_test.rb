require 'test_plugin_helper'

class HostgroupOverriderTest < ActiveSupport::TestCase
  setup do
    ForemanOpenscap::ScapContent.any_instance.stubs(:fetch_profiles).returns({ 'test_profile_key' => 'test_profile_title' })

    @scap_content = FactoryBot.create(:scap_content)
    @scap_profile = FactoryBot.create(:scap_content_profile, :scap_content => @scap_content)
  end

  test 'should populate puppet overrides' do
    puppet_class, env, port_param, server_param = setup_puppet_class.values_at :puppet_class, :env, :port_param, :server_param

    proxy = FactoryBot.create(:openscap_proxy, :url => 'https://override-keys.example.com:8998')

    hostgroup = FactoryBot.create(:hostgroup, :environment_id => env.id, :openscap_proxy_id => proxy.id, :puppet => FactoryBot.create(:hostgroup_puppet_facet))
    refute hostgroup.puppetclasses.include? puppet_class
    assert LookupValue.where(:match => "hostgroup=#{hostgroup.to_label}",
                             :lookup_key_id => port_param.id,
                             :value => '8998').empty?
    assert LookupValue.where(:match => "hostgroup=#{hostgroup.to_label}",
                             :lookup_key_id => server_param.id,
                             :value => 'override-keys.example.com').empty?

    port_param.override = true
    port_param.save
    server_param.override = true
    server_param.save
    hostgroup.puppetclasses << puppet_class
    policy = FactoryBot.build(:policy, :scap_content => @scap_content,
                                       :scap_content_profile => @scap_profile,
                                       :deploy_by => 'puppet',
                                       :hostgroup_ids => [hostgroup.id])
    policy.save
    refute LookupValue.where(:match => "hostgroup=#{hostgroup.to_label}",
                             :lookup_key_id => port_param.id,
                             :value => 8998).empty?
    refute LookupValue.where(:match => "hostgroup=#{hostgroup.to_label}",
                             :lookup_key_id => server_param.id,
                             :value => 'override-keys.example.com').empty?
  end

  test "should return when policy has blank deploy_by" do
    policy = FactoryBot.build(:policy, :scap_content => @scap_content,
                                       :scap_content_profile => @scap_profile)
    overrider = ForemanOpenscap::HostgroupOverrider.new(policy)
    overrider.expects(:populate_overrides).never
    overrider.populate
  end

  test "should return when deploy_by type is not supported" do
    policy = FactoryBot.build(:policy, :scap_content => @scap_content,
                                       :scap_content_profile => @scap_profile,
                                       :deploy_by => 'salt')
    overrider = ForemanOpenscap::HostgroupOverrider.new(policy)
    overrider.expects(:populate_overrides).never
    overrider.populate
  end

  test "should return when deployment type is not available" do
    ForemanOpenscap::ClientConfig::Ansible.any_instance.stubs(:available?).returns(false)
    policy = FactoryBot.build(:policy, :scap_content => @scap_content,
                                       :scap_content_profile => @scap_profile,
                                       :deploy_by => 'ansible')
    overrider = ForemanOpenscap::HostgroupOverrider.new(policy)
    overrider.expects(:populate_overrides).never
    overrider.populate
  end

  test "should return when config has unmanaged overrides" do
    policy = FactoryBot.build(:policy, :scap_content => @scap_content,
                                       :scap_content_profile => @scap_profile,
                                       :deploy_by => 'manual')
    overrider = ForemanOpenscap::HostgroupOverrider.new(policy)
    overrider.expects(:populate_overrides).never
    overrider.populate
  end
end
