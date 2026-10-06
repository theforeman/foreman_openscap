require 'test_plugin_helper'

class Api::V2::Compliance::HostsBulkActionsControllerTest < ActionController::TestCase
  tests Api::V2::Compliance::HostsBulkActionsController

  setup do
    as_admin do
      @organization = FactoryBot.create(:organization)
      @location = FactoryBot.create(:location)
      @proxy = FactoryBot.create(:openscap_proxy,
                                 :organizations => [@organization],
                                 :locations => [@location])
      @host1 = FactoryBot.create(:host, :managed,
                                 :organization => @organization,
                                 :location => @location)
      @host2 = FactoryBot.create(:host, :managed,
                                 :organization => @organization,
                                 :location => @location)
      @host_ids = [@host1.id, @host2.id]
      @policy = FactoryBot.create(:policy,
                                  :organizations => [@organization],
                                  :locations => [@location])
      @policy.scap_content.update(:organization_ids => [@organization.id], :location_ids => [@location.id])
    end
  end

  def valid_bulk_params(host_ids = @host_ids)
    {
      :organization_id => @organization.id,
      :location_id => @location.id,
      :included => {
        :ids => host_ids,
      },
      :excluded => {
        :ids => [],
      },
    }
  end

  test "should assign openscap proxy to selected hosts" do
    put :change_openscap_proxy,
        params: valid_bulk_params.merge(:openscap_proxy_id => @proxy.id),
        session: set_session_user

    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Updated hosts: OpenSCAP Proxy is set to/, response['message'])
    assert_includes response['message'], @proxy.name

    [@host1, @host2].each do |host|
      host.reload
      assert_equal @proxy.id, host.openscap_proxy_id
    end
  end

  test "should require openscap_proxy_id" do
    put :change_openscap_proxy,
        params: valid_bulk_params,
        session: set_session_user

    assert_response :unprocessable_entity
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/openscap_proxy_id/, response['error']['message'])
  end

  test "should return error when proxy is not found" do
    put :change_openscap_proxy,
        params: valid_bulk_params.merge(:openscap_proxy_id => 0),
        session: set_session_user

    assert_response :unprocessable_entity
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/OpenSCAP Proxy with id .* not found/, response['error']['message'])
  end

  test "should return error when proxy lacks Openscap feature" do
    other_proxy = FactoryBot.create(:smart_proxy,
                                    :organizations => [@organization],
                                    :locations => [@location])
    openscap_feature = Feature.find_by(:name => 'Openscap')
    other_proxy.features.delete(openscap_feature) if openscap_feature
    refute other_proxy.reload.has_feature?('Openscap')

    put :change_openscap_proxy,
        params: valid_bulk_params.merge(:openscap_proxy_id => other_proxy.id),
        session: set_session_user

    assert_response :unprocessable_entity
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/OpenSCAP Proxy does not have the OpenSCAP feature/, response['error']['message'])
  end

  test "should assign openscap proxy for a single host" do
    put :change_openscap_proxy,
        params: valid_bulk_params([@host1.id]).merge(:openscap_proxy_id => @proxy.id),
        session: set_session_user

    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Updated host: OpenSCAP Proxy is set to/, response['message'])

    @host1.reload
    assert_equal @proxy.id, @host1.openscap_proxy_id
    @host2.reload
    assert_nil @host2.openscap_proxy_id
  end

  test "should report failed and successful counts on partial failure" do
    Host.any_instance.stubs(:save).returns(false).then.returns(true)

    put :change_openscap_proxy,
        params: valid_bulk_params.merge(:openscap_proxy_id => @proxy.id),
        session: set_session_user

    assert_response :unprocessable_entity
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Failed to assign OpenSCAP Proxy to 1 of 2 hosts/, response['error']['message'])
    assert_match(/Successfully updated 1 host/, response['error']['message'])
    assert_equal 1, response['error']['failed_host_ids'].size
    assert_includes @host_ids, response['error']['failed_host_ids'].first
  end

  test "should report only failures when all hosts fail" do
    Host.any_instance.stubs(:save).returns(false)

    put :change_openscap_proxy,
        params: valid_bulk_params.merge(:openscap_proxy_id => @proxy.id),
        session: set_session_user

    assert_response :unprocessable_entity
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Failed to assign OpenSCAP Proxy to 2 of 2 hosts/, response['error']['message'])
    refute_match(/Successfully updated/, response['error']['message'])
    assert_equal @host_ids.sort, response['error']['failed_host_ids'].sort
  end

  test "should assign compliance policy to selected hosts" do
    put :assign_compliance_policy,
        params: valid_bulk_params.merge(:policy_id => @policy.id),
        session: set_session_user

    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Updated hosts: Assigned with compliance policy/, response['message'])
    assert_includes response['message'], @policy.name

    @policy.reload
    assert_includes @policy.hosts.map(&:id), @host1.id
    assert_includes @policy.hosts.map(&:id), @host2.id
  end

  test "should assign compliance policy to a single host" do
    put :assign_compliance_policy,
        params: valid_bulk_params([@host1.id]).merge(:policy_id => @policy.id),
        session: set_session_user

    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Updated host: Assigned with compliance policy/, response['message'])

    @policy.reload
    assert_includes @policy.hosts.map(&:id), @host1.id
    refute_includes @policy.hosts.map(&:id), @host2.id
  end

  test "should require policy_id for assign" do
    put :assign_compliance_policy,
        params: valid_bulk_params,
        session: set_session_user

    assert_response :unprocessable_entity
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/policy_id/, response['error']['message'])
  end

  test "should return error when policy is not found for assign" do
    put :assign_compliance_policy,
        params: valid_bulk_params.merge(:policy_id => 0),
        session: set_session_user

    assert_response :unprocessable_entity
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Compliance policy with id .* not found/, response['error']['message'])
  end

  test "should unassign compliance policy from selected hosts" do
    as_admin do
      @host1.policies = [@policy]
      @host1.save!
      @host2.policies = [@policy]
      @host2.save!
    end

    put :unassign_compliance_policy,
        params: valid_bulk_params.merge(:policy_id => @policy.id),
        session: set_session_user

    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Updated hosts: Unassigned from compliance policy/, response['message'])
    assert_includes response['message'], @policy.name

    @policy.reload
    refute_includes @policy.hosts.map(&:id), @host1.id
    refute_includes @policy.hosts.map(&:id), @host2.id
  end

  test "should unassign compliance policy from a single host" do
    as_admin do
      @host1.policies = [@policy]
      @host1.save!
      @host2.policies = [@policy]
      @host2.save!
    end

    put :unassign_compliance_policy,
        params: valid_bulk_params([@host1.id]).merge(:policy_id => @policy.id),
        session: set_session_user

    assert_response :success
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Updated host: Unassigned from compliance policy/, response['message'])

    @policy.reload
    refute_includes @policy.hosts.map(&:id), @host1.id
    assert_includes @policy.hosts.map(&:id), @host2.id
  end

  test "should require policy_id for unassign" do
    put :unassign_compliance_policy,
        params: valid_bulk_params,
        session: set_session_user

    assert_response :unprocessable_entity
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/policy_id/, response['error']['message'])
  end

  test "should return error when policy is not found for unassign" do
    put :unassign_compliance_policy,
        params: valid_bulk_params.merge(:policy_id => 0),
        session: set_session_user

    assert_response :unprocessable_entity
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/Compliance policy with id .* not found/, response['error']['message'])
  end

  context "forbidden user" do
    setup do
      @user = FactoryBot.create(:user, :admin => false,
                                :organizations => [@organization],
                                :locations => [@location])
    end

    test "should forbid assign compliance policy without assign_policies permission" do
      setup_user('edit', 'hosts', nil, @user)

      put :assign_compliance_policy,
          params: valid_bulk_params.merge(:policy_id => @policy.id),
          session: set_session_user(@user)

      assert_forbidden_missing_permission('assign_policies')
    end

    test "should forbid unassign compliance policy without assign_policies permission" do
      setup_user('edit', 'hosts', nil, @user)

      put :unassign_compliance_policy,
          params: valid_bulk_params.merge(:policy_id => @policy.id),
          session: set_session_user(@user)

      assert_forbidden_missing_permission('assign_policies')
    end

    test "should forbid change openscap proxy without edit_hosts permission" do
      setup_user('assign', 'policies', nil, @user)

      put :change_openscap_proxy,
          params: valid_bulk_params.merge(:openscap_proxy_id => @proxy.id),
          session: set_session_user(@user)

      assert_forbidden_missing_permission('edit_hosts')
    end

    test "should forbid assign compliance policy when user cannot edit hosts" do
      setup_user('assign', 'policies', nil, @user)

      put :assign_compliance_policy,
          params: valid_bulk_params.merge(:policy_id => @policy.id),
          session: set_session_user(@user)

      assert_response :forbidden
      response = ActiveSupport::JSON.decode(@response.body)
      assert_match(/No hosts matched search, or action unauthorized for selected hosts/, response['error']['message'])
    end
  end

  private

  def assert_forbidden_missing_permission(permission)
    assert_response :forbidden
    response = ActiveSupport::JSON.decode(@response.body)
    assert_includes response['error']['missing_permissions'], permission
  end
end
