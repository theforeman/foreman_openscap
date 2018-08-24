require 'test_plugin_helper'

class PuppetOverridesTest < ActiveSupport::TestCase
  setup do
    ForemanOpenscap::ScapContent.any_instance.stubs(:fetch_profiles).returns({ 'test_profile_key' => 'test_profile_title' })
    @scap_content = FactoryBot.create(:scap_content)
    @scap_profile = FactoryBot.create(:scap_content_profile, :scap_content => @scap_content)
  end

  test "should override puppet class parameters" do
    env = FactoryBot.create(:environment)
    puppet_class = FactoryBot.create(:puppetclass, :name => 'foreman_scap_client')
    server_param = FactoryBot.create(:puppetclass_lookup_key, :key => 'server')
    port_param = FactoryBot.create(:puppetclass_lookup_key, :key => 'port')
    policies_param = FactoryBot.create(:puppetclass_lookup_key, :key => 'policies')
    FactoryBot.create(:environment_class,
                      :puppetclass_id => puppet_class.id,
                      :environment_id => env.id,
                      :puppetclass_lookup_key_id => server_param.id)
    FactoryBot.create(:environment_class,
                      :puppetclass_id => puppet_class.id,
                      :environment_id => env.id,
                      :puppetclass_lookup_key_id => port_param.id)
    FactoryBot.create(:environment_class,
                      :puppetclass_id => puppet_class.id,
                      :environment_id => env.id,
                      :puppetclass_lookup_key_id => policies_param.id)
    refute server_param.override
    refute port_param.override
    refute policies_param.override
    FactoryBot.create(:policy, :scap_content => @scap_content, :scap_content_profile => @scap_content_profile)

    assert server_param.reload.override
    assert port_param.reload.override
    assert policies_param.reload.override
    assert_equal '<%= @host.policies_enc %>', policies_param.default_value
  end
end
