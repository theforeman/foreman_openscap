require 'test_plugin_helper'
require 'application_helper'

class OpenscapProxiesControllerTest < ActionController::TestCase
  include ActionView::Helpers::DateHelper
  include ApplicationHelper

  test "should render spool error" do
    spool_error = { "timestamp" => 1_487_144_633.951_368, "level" => "ERROR", "message" => "Failed to parse Arf Report in test" }
    OpenscapProxiesController.any_instance.stubs(:find_spool_error).returns(spool_error)
    proxy = FactoryBot.create(:openscap_proxy)
    get :openscap_spool, :params => { :id => proxy.id }, :session => set_session_user
    assert_template :partial => 'smart_proxies/_openscap_spool'
    assert @response.body.match(date_time_relative_value(Time.at(spool_error["timestamp"])))
  end
end
