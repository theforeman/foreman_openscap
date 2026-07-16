require 'test_plugin_helper'

class Api::V2::HostsBulkActionsControllerTest < ActionController::TestCase
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
    assert_match(/OpenSCAP Proxy set to/, response['message'])
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
    assert_match(/No OpenSCAP Proxy selected/, response['error']['message'])
  end

  test "should return error when proxy is not found" do
    put :change_openscap_proxy,
        params: valid_bulk_params.merge(:openscap_proxy_id => 0),
        session: set_session_user

    assert_response :unprocessable_entity
    response = ActiveSupport::JSON.decode(@response.body)
    assert_match(/not found/, response['error']['message'])
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
    assert_match(/OpenSCAP feature/, response['error']['message'])
  end

  test "should assign openscap proxy for a single host" do
    put :change_openscap_proxy,
        params: valid_bulk_params([@host1.id]).merge(:openscap_proxy_id => @proxy.id),
        session: set_session_user

    assert_response :success
    @host1.reload
    assert_equal @proxy.id, @host1.openscap_proxy_id
    @host2.reload
    assert_nil @host2.openscap_proxy_id
  end
end
