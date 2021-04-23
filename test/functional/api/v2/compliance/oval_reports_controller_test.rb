require 'test_plugin_helper'

class Api::V2::Compliance::OvalReportsControllerTest < ActionController::TestCase
  setup do
    @params = {
      :oval_results => ForemanOpenscap::CveFixtures.new.one,
      :oval_policy_id => 5,
      :date => Time.now.to_i
    }
  end

  test 'should accept new CVEs for host' do
    host = FactoryBot.create(:host)
    post :create, :params => @params.merge(:cname => host.name), :session => set_session_user

    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal 'ok', response['result']
    assert_response :success
  end

  test 'should show host errors on CVEs upload' do
    proxy = FactoryBot.create(:smart_proxy)
    host = FactoryBot.create(:host, :puppet_proxy => proxy, :environment => FactoryBot.create(:environment))
    SmartProxy.any_instance.stubs(:smart_proxy_features).returns([])
    post :create, :params => @params.merge(:cname => host.name), :session => set_session_user

    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal 'fail', response['result']
    refute response['errors'].empty?
    assert_response :unprocessable_entity
  end
end
