require 'test_plugin_helper'

class OpenscapProxiesControllerTest < ActionController::TestCase
  include ActionView::Helpers::DateHelper

  test "should render spool error" do
    spool_error = { "timestamp" => 1_487_144_633.951_368, "level" => "ERROR", "message" => "Failed to parse Arf Report in test" }
    OpenscapProxiesController.any_instance.stubs(:find_spool_error).returns(spool_error)
    proxy = FactoryGirl.create(:openscap_proxy)
    get :openscap_spool, { :id => proxy.id }, set_session_user
    assert_template :partial => 'smart_proxies/_openscap_spool'
    assert @response.body.match(time_ago_in_words(Time.at(spool_error["timestamp"])))
  end
end
