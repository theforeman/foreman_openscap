require 'test_plugin_helper'

class Api::V2::Compliance::OvalReportsControllerTest < ActionController::TestCase
  test 'should accept new CVEs for host' do
    host = FactoryBot.create(:host)
    params = {
      :oval_results => ForemanOpenscap::CveFixtures.new.one,
      :cname => host.name,
      :oval_policy_id => 5,
      :date => Time.now.to_i
    }

    post :create, :params => params, :session => set_session_user

    response = ActiveSupport::JSON.decode(@response.body)
    assert_equal 'ok', response['result']
    assert_response :success
  end
end
