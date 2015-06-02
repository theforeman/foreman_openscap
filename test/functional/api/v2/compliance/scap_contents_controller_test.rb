require 'test_plugin_helper'

class Api::V2::Compliance::ScapContentsControllerTest < ActionController::TestCase

  test "should get index" do
    FactoryGirl.create(:scap_content)
    get :index, {}, set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['results'].any?
    assert_response :success
  end

  test "should return xml of scap content" do
    scap_content = FactoryGirl.create(:scap_content)
    get :show, { :id => scap_content.id }, set_session_user
    assert(@response.header['Content-Type'], 'application/xml')
    assert_response :success
  end

  test "should create invalid scap content" do
    post :create, {}, set_session_user
    assert_response :unprocessable_entity
  end

  test "should create scap content" do
    # Skipped as API does not support uploading files
  end

  test "should update scap content" do
    scap_content = FactoryGirl.create(:scap_content)
    put :update, { :id => scap_content.id, :scap_content => {:title => 'RHEL7 SCAP'}}, set_session_user
    assert_response :success
    assert scap_content.title, 'RHEL7 SCAP'
  end

  test "should not update invalid scap content"  do
    scap_content = FactoryGirl.create(:scap_content)
    put :update, { :id => scap_content.id, :scap_content => {:scap_file => '<xml>blah</xml>'}}, set_session_user
    assert_response :unprocessable_entity
  end

  test "should destory scap content" do
    scap_content = FactoryGirl.create(:scap_content)
    delete :destroy, { :id => scap_content.id }, set_session_user
    assert_response :ok
    refute Scaptimony::ScapContent.exists?(scap_content.id)
  end
end