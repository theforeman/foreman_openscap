require 'test_plugin_helper'

class Api::V2::Compliance::ScapContentsControllerTest < ActionController::TestCase
  test "should get index" do
    FactoryBot.create(:scap_content)
    get :index, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['results'].any?
    assert_response :success
  end

  test "should return xml of scap content" do
    scap_content = FactoryBot.create(:scap_content)
    get :xml, :params => { :id => scap_content.id }, :session => set_session_user
    assert_equal 'application/xml', @response.media_type
    assert_response :success
    assert_equal scap_content.scap_file.b, @response.body.b
  end

  test 'XML download still requires permission to view SCAP content' do
    scap_content = FactoryBot.create(:scap_content)
    user = FactoryBot.create(:user, :admin => false)
    user.roles = []
    # API test authentication uses User.current before the supplied session.
    User.current = user
    ActiveStorage::Blob.any_instance.expects(:download).never
    get :xml, :params => { :id => scap_content.id }, :session => set_session_user(user)
    assert_response :forbidden
  end

  test "should not create invalid scap content" do
    post :create, :session => set_session_user
    assert_response :unprocessable_entity
  end

  test "should create scap content" do
    # Skipped as API does not support uploading files
  end

  test "should update scap content" do
    scap_content = FactoryBot.create(:scap_content)
    put :update, :params => { :id => scap_content.id, :scap_content => { :title => 'RHEL7 SCAP' } }, :session => set_session_user
    assert_response :success
    assert scap_content.title, 'RHEL7 SCAP'
  end

  test "should not update invalid scap content" do
    skip("Solve 'ActiveRecord::RecordInvalid' error")
    ProxyAPI::Openscap.any_instance.stubs(:validate_scap_content).returns({ 'errors' => ['Invalid file'] })
    scap_content = FactoryBot.create(:scap_content)
    put :update, :params => { :id => scap_content.id, :scap_content => { :scap_file => '<xml>blah</xml>' } }, :session => set_session_user
    assert_response :unprocessable_entity
  end

  test "should destory scap content" do
    scap_content = FactoryBot.create(:scap_content)
    delete :destroy, :params => { :id => scap_content.id }, :session => set_session_user
    assert_response :ok
    refute ForemanOpenscap::ScapContent.exists?(scap_content.id)
  end
end
