require 'test_plugin_helper'

class Api::V2::Compliance::PoliciesControllerTest < ActionController::TestCase
  setup do
    Scaptimony::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
  end

  test "should return xml of scap content" do
    policy = FactoryGirl.create(:policy)
    get :content, { :id => policy.id }, set_session_user
    assert(@response.header['Content-Type'], 'application/xml')
    assert_response :success
  end
end
