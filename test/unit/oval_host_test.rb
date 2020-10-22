require 'test_plugin_helper'

class OvalHostTest < ActiveSupport::TestCase
  test 'should show oval policies in enc' do
    setup_ansible

    content = FactoryBot.create(:oval_content)
    policy = FactoryBot.create(:oval_policy, :oval_content => content)
    proxy = FactoryBot.create(:openscap_proxy)
    host = FactoryBot.create(:oval_host, :ansible_roles => [@ansible_role], :openscap_proxy => proxy)
    facet = FactoryBot.create(:oval_facet, :host => host, :oval_policies => [policy])

    host_params = host.info["parameters"]
    policies = JSON.parse(host_params[@config.policies_param])
    assert_equal 1, policies.length
    assert_equal policies.first["id"], policy.id

    assert_equal host_params[@config.port_param], proxy.port.to_s
    assert_equal host_params[@config.server_param], proxy.hostname
  end

  def setup_ansible
    @config = ForemanOpenscap::ClientConfig::Ansible.new(::ForemanOpenscap::OvalPolicy)
    @ansible_role = FactoryBot.create(:ansible_role, :name => @config.ansible_role_name)
    @port_key = FactoryBot.create(:ansible_variable,
      :key => @config.port_param,
      :ansible_role => @ansible_role,
      :override => true,
    )
    @server_key = FactoryBot.create(:ansible_variable,
      :key => @config.server_param,
      :ansible_role => @ansible_role,
      :override => true
    )
    @policies_param = FactoryBot.create(:ansible_variable,
      :key => @config.policies_param,
      :ansible_role => @ansible_role,
      :override => true,
      :default_value => @config.policies_param_default_value
    )
  end
end
