require 'test_plugin_helper'

class Api::V2::Compliance::OvalContentsControllerTest < ActionController::TestCase
  test "should get index" do
    FactoryBot.create(:oval_content)
    get :index, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['results'].any?
    assert_response :success
  end

  test "should create OVAL content" do
    post :create, :params => { :oval_content => { :name => 'OVAL test', :scap_file => '<xml>test</xml>' } }, :session => set_session_user
    assert_response :success
  end

  test "should update OVAL content" do
    new_name = 'RHEL7 OVAL'
    oval_content = FactoryBot.create(:oval_content)
    put :update, :params => { :id => oval_content.id, :oval_content => { :name => new_name } }, :session => set_session_user
    assert_response :success
    assert oval_content.name, new_name
  end

  test "should destory OVAL content" do
    oval_content = FactoryBot.create(:oval_content)
    delete :destroy, :params => { :id => oval_content.id }, :session => set_session_user
    assert_response :ok
    refute ForemanOpenscap::OvalContent.exists?(oval_content.id)
  end
end
