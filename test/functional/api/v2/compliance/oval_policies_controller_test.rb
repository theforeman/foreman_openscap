require 'test_plugin_helper'
require 'base64'

class Api::V2::Compliance::OvalPoliciesControllerTest < ActionController::TestCase
  setup do
    @attributes = { :oval_policy => { :name => 'my_policy', :period => 'weekly', :weekday => 'friday' } }
    @config = ForemanOpenscap::ClientConfig::Ansible.new(::ForemanOpenscap::OvalPolicy)
  end

  test "should get index of OVAL policies" do
    FactoryBot.create(:oval_policy)
    get :index, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert !response['results'].empty?
    assert_response :success
  end

  test "should show OVAL policy" do
    policy = FactoryBot.create(:oval_policy)
    get :show, :params => { :id => policy.to_param }, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['name'], policy.name
    assert_response :success
  end

  test "should update OVAL policy" do
    policy = FactoryBot.create(:oval_policy)
    put :update, :params => { :id => policy.id, :oval_policy => { :period => 'monthly', :day_of_month => 15 } }
    updated_policy = ActiveSupport::JSON.decode(@response.body)
    assert(updated_policy['period'], 'monthly')
    assert_response :ok
  end

  test "should not update invalid OVAL policy" do
    policy = FactoryBot.create(:oval_policy)
    put :update, :params => { :id => policy.id, :oval_policy => { :name => '' } }
    assert_response :unprocessable_entity
  end

  test "should create OVAL policy" do
    post :create, :params => @attributes, :session => set_session_user
    assert_response :created
  end

  test "should not create invalid OVAL policy" do
    post :create, :session => set_session_user
    assert_response :unprocessable_entity
  end

  test "should destroy OVAL policy" do
    policy = FactoryBot.create(:oval_policy)
    delete :destroy, :params => { :id => policy.id }, :session => set_session_user
    assert_response :ok
    refute ForemanOpenscap::OvalPolicy.exists?(policy.id)
  end

  test "should return error when OVAL policy not found" do
    policy = FactoryBot.create(:oval_policy)
    get :show, :params => { :id => policy.id + 1 }, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['error']
    assert_response :missing
  end

  test "should assign policy to multiple hosts correctly" do
    proxy = FactoryBot.create(:openscap_proxy)
    host1 = FactoryBot.create(:compliance_host, :openscap_proxy => proxy)
    host2 = FactoryBot.create(:compliance_host, :openscap_proxy => proxy)
    policy = FactoryBot.create(:oval_policy)
    setup_ansible

    assert_empty host1.oval_policies
    assert_empty host2.oval_policies

    post :assign_hosts, :params => { :id => policy.id, :host_ids => [host1, host2].pluck(:id) }, :session => set_session_user
    assert_equal "OVAL policy successfully configured with hosts.", ActiveSupport::JSON.decode(@response.body)['message']

    assert_equal 2, host1.lookup_values.count
    server_value = @server_key.lookup_values.find_by :match => "fqdn=#{host1.name}"
    port_value = @port_key.lookup_values.find_by :match => "fqdn=#{host1.name}"
    assert_equal proxy.hostname, server_value.value
    assert_equal proxy.port, port_value.value
  end

  test "should assign policy to multiple hostgroups correctly" do
    proxy = FactoryBot.create(:openscap_proxy)
    hg1 = FactoryBot.create(:hostgroup, :openscap_proxy => proxy)
    hg2 = FactoryBot.create(:hostgroup, :openscap_proxy => proxy)
    policy = FactoryBot.create(:oval_policy)
    setup_ansible

    assert_empty hg1.oval_policies
    assert_empty hg2.oval_policies

    post :assign_hostgroups, :params => { :id => policy.id, :hostgroup_ids => [hg1, hg2].pluck(:id) }, :session => set_session_user
    assert_equal "OVAL policy successfully configured with hostgroups.", ActiveSupport::JSON.decode(@response.body)['message']

    assert_equal 2, hg1.lookup_values.count
    server_value = @server_key.lookup_values.find_by :match => "hostgroup=#{hg1.name}"
    port_value = @port_key.lookup_values.find_by :match => "hostgroup=#{hg1.name}"
    assert_equal proxy.hostname, server_value.value
    assert_equal proxy.port, port_value.value
  end

  test "should not assign policy to hostgroup without openscap proxy" do
    hg = FactoryBot.create(:hostgroup)
    policy = FactoryBot.create(:oval_policy)
    setup_ansible

    assert_empty hg.oval_policies

    post :assign_hostgroups, :params => { :id => policy.id, :hostgroup_ids => hg.id }, :session => set_session_user
    res = ActiveSupport::JSON.decode(@response.body)['results'].first
    assert_equal "Was Hostgroup configured successfully?", res['title']
    assert_equal "fail", res['result']
    assert_equal "Assign openscap_proxy to #{hg.name} before proceeding.", res['fail_message']
    hg.reload
    assert_empty hg.oval_policies
  end

  test "should not assign policy to hostgroup when ansible role not present" do
    hg = FactoryBot.create(:hostgroup)
    policy = FactoryBot.create(:oval_policy)
    assert_empty hg.oval_policies

    post :assign_hostgroups, :params => { :id => policy.id, :hostgroup_ids => hg.id }, :session => set_session_user
    res = ActiveSupport::JSON.decode(@response.body)['results'].first
    assert_equal 'theforeman.foreman_scap_client Ansible Role not found, please import it before running this action again.', res['fail_message']
    hg.reload
    assert_empty hg.oval_policies
  end

  test "should show oval content" do
    file = Base64.encode64(read_oval_content('ansible-2.9.oval.xml.bz2'))
    oval_content = FactoryBot.create(:oval_content, :scap_file => file)
    policy = FactoryBot.create(:oval_policy, :oval_content => oval_content)

    get :oval_content, :params => { :id => policy.id }
    assert response.body, file
  end

  def setup_ansible
    @ansible_role = FactoryBot.create(:ansible_role, :name => @config.ansible_role_name)
    @port_key = FactoryBot.create(:ansible_variable, :key => @config.port_param, :ansible_role => @ansible_role)
    @server_key = FactoryBot.create(:ansible_variable, :key => @config.server_param, :ansible_role => @ansible_role)
    FactoryBot.create(:ansible_variable, :key => @config.policies_param, :ansible_role => @ansible_role)
  end

  def read_oval_content(file_name)
    File.read "#{ForemanOpenscap::Engine.root}/test/files/oval_contents/#{file_name}"
  end
end
