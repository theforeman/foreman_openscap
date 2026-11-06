require 'test_plugin_helper'

class ComplianceHostsControllerTest < ActionController::TestCase
  setup do
    @host = FactoryBot.create(:compliance_host)
  end

  test 'should show compliance host' do
    get :show, :params => { :id => @host.id }, :session => set_session_user
    assert_response :success
  end
end
