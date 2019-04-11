require 'test_plugin_helper'

module Api
  module V2
    class HostsControllerTest < ActionController::TestCase
      test "should get policies enc" do
        policy = FactoryBot.create(:policy)
        host = FactoryBot.create(:compliance_host, :policies => [policy])

        get :policies_enc, :params => { :id => host.id }, :session => set_session_user
        assert_response :success
        response = ActiveSupport::JSON.decode(@response.body)
        assert_equal policy.id, response.first['id']
      end
    end
  end
end
