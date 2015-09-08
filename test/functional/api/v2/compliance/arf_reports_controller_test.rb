require 'test_plugin_helper'

class Api::V2::Compliance::ArfReportsControllerTest < ActionController::TestCase
  setup do
    # override validation of policy (puppetclass, lookup_key overrides)
    ForemanOpenscap::Policy.any_instance.stubs(:valid?).returns(true)
  end
  test "should get index" do
    FactoryGirl.create(:arf_report)
    get :index, {}, set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert_not response['results'].empty?
    assert_response :success
  end

  test "should get show" do
    get :show, { :id => FactoryGirl.create(:arf_report).to_param }, set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    refute response['passed'].blank?
    refute response['failed'].blank?
    refute response['othered'].blank?
    assert_response :success
  end
end