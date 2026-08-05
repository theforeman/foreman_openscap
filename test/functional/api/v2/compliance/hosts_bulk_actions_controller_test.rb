require 'test_plugin_helper'

class Api::V2::Compliance::HostsBulkActionsControllerTest < ActionController::TestCase
  tests Api::V2::Compliance::HostsBulkActionsController

  def setup
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
end
