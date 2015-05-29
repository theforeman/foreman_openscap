require 'test_plugin_helper'

class Api::V2::Compliance::PoliciesControllerTest < ActionController::TestCase
  setup do
    Scaptimony::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
  end

  test "should get index" do
    FactoryGirl.create(:policy)
    get :index, {}, set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['results'].length > 0
    assert_response :success
  end

  test "should show a policy" do
    policy = FactoryGirl.create(:policy)
    get :show, { :id => policy.to_param }, set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['name'], policy.name
    assert_response :success
  end

  test "should update a policy" do
    policy = FactoryGirl.create(:policy)
    put :update, {:id => policy.id, :policy => {:period => 'monthly'}}
    updated_policy = ActiveSupport::JSON.decode(@response.body)
    assert(updated_policy['period'], 'monthly')
    assert_response :ok
  end

  test "should not update invalid" do
    policy = FactoryGirl.create(:policy)
    put :update, {:id => policy.id, :policy => {:name => 'say my name'}}
    assert_response :unprocessable_entity
  end

  test "should create a policy" do
    scap_content_profile = FactoryGirl.create(:scap_content_profile)
    attributes = {:policy => {:name => 'my_policy', :scap_content_profile_id => scap_content_profile.id, :scap_content_id => scap_content_profile.scap_content_id}}
    post :create, attributes, set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['scap_content_profile_id'], scap_content_profile.to_param
    assert_response :created
  end

  test "should not create invalid policy" do
    post :create, {}, set_session_user
    assert_response :unprocessable_entity
  end

  test "should destroy" do
    policy = FactoryGirl.create(:policy)
    delete :destroy, { :id => policy.id }, set_session_user
    assert_response :ok
    refute Scaptimony::Policy.exists?(policy.id)
  end

  test "should return xml of scap content" do
    policy = FactoryGirl.create(:policy)
    get :content, { :id => policy.id }, set_session_user
    assert(@response.header['Content-Type'], 'application/xml')
    assert_response :success
  end
end