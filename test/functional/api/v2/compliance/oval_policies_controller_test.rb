require 'test_plugin_helper'

class Api::V2::Compliance::OvalPoliciesControllerTest < ActionController::TestCase
  setup do
    @attributes = { :oval_policy => { :name => 'my_policy', :period => 'weekly', :weekday => 'friday' } }
  end

  test "should get index of OVAL policies" do
    FactoryBot.create(:oval_policy)
    get :index, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert !response['results'].empty?
    assert_response :success
  end

  test "should show OVAL policy" do
    policy = FactoryBot.create(:oval_policy)
    get :show, :params => { :id => policy.to_param }, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['name'], policy.name
    assert_response :success
  end

  test "should update OVAL policy" do
    policy = FactoryBot.create(:oval_policy)
    put :update, :params => { :id => policy.id, :oval_policy => { :period => 'monthly', :day_of_month => 15 } }
    updated_policy = ActiveSupport::JSON.decode(@response.body)
    assert(updated_policy['period'], 'monthly')
    assert_response :ok
  end

  test "should not update invalid OVAL policy" do
    policy = FactoryBot.create(:oval_policy)
    put :update, :params => { :id => policy.id, :oval_policy => { :name => '' } }
    assert_response :unprocessable_entity
  end

  test "should create OVAL policy" do
    post :create, :params => @attributes, :session => set_session_user
    assert_response :created
  end

  test "should not create invalid OVAL policy" do
    post :create, :session => set_session_user
    assert_response :unprocessable_entity
  end

  test "should destroy OVAL policy" do
    policy = FactoryBot.create(:oval_policy)
    delete :destroy, :params => { :id => policy.id }, :session => set_session_user
    assert_response :ok
    refute ForemanOpenscap::OvalPolicy.exists?(policy.id)
  end

  test "should return error when OVAL policy not found" do
    policy = FactoryBot.create(:oval_policy)
    get :show, :params => { :id => policy.id + 1 }, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['error']
    assert_response :missing
  end
end
