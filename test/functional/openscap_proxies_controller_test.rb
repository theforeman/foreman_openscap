require 'test_plugin_helper'

class OpenscapProxiesControllerTest < ActionController::TestCase
  include ActionView::Helpers::DateHelper
  include ApplicationHelper

  test "should render spool error" do
    spool_error = { "errors_count" => 4 }
    ProxyStatus::OpenscapSpool.any_instance.stubs(:spool_status).returns(spool_error)
    proxy = FactoryBot.create(:openscap_proxy)
    get :openscap_spool, :params => { :id => proxy.id }, :session => set_session_user
    assert_template :partial => 'smart_proxies/_openscap_spool'
    assert @response.body.match('4 spool errors detected, inspect the appropriate file directly on proxy')
  end
end
