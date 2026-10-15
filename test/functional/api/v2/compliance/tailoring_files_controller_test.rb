require 'test_plugin_helper'

class Api::V2::Compliance::TailoringFilesControllerTest < ActionController::TestCase
  test "should get index" do
    FactoryBot.create(:tailoring_file)
    get :index, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['results'].any?
    assert_response :success
  end

  test "should return xml of tailoring_file" do
    tailoring_file = FactoryBot.create(:tailoring_file)
    get :xml, :params => { :id => tailoring_file.id }, :session => set_session_user
    assert_equal 'application/xml', @response.media_type
    assert_response :success
    assert_equal tailoring_file.scap_file.b, @response.body.b
  end

  test 'XML download still requires permission to view tailoring files' do
    tailoring_file = FactoryBot.create(:tailoring_file)
    user = FactoryBot.create(:user, :admin => false)
    user.roles = []
    # API test authentication uses User.current before the supplied session.
    User.current = user
    ActiveStorage::Blob.any_instance.expects(:download).never
    get :xml, :params => { :id => tailoring_file.id }, :session => set_session_user(user)
    assert_response :forbidden
  end

  test "should not create invalid tailoring_file" do
    post :create, :session => set_session_user
    assert_response :unprocessable_entity
  end

  test "should create tailoring_file" do
    tf = FactoryBot.build(:tailoring_file)
    tf_params = { :name => tf.name, :original_filename => tf.original_filename, :scap_file => tf.scap_file }
    post :create, :params => tf_params, :session => set_session_user
    assert_response :success
  end

  test "should update tailoring_file" do
    tailoring_file = FactoryBot.create(:tailoring_file)
    put :update, :params => { :id => tailoring_file.id, :tailoring_file => { :name => 'RHEL7 SCAP' } }, :session => set_session_user
    assert_response :success
    assert tailoring_file.name, 'RHEL7 SCAP'
  end

  test "should not update invalid tailoring_file" do
    tailoring_file = FactoryBot.create(:tailoring_file)
    ProxyAPI::Openscap.any_instance.stubs(:validate_scap_file).returns({ 'errors' => ['Invalid file'] })
    put :update, :params => { :id => tailoring_file.id, :tailoring_file => { :scap_file => '<xml>blah</xml>' } }, :session => set_session_user
    assert_response :unprocessable_entity
  end

  test "should destory tailoring_file" do
    tailoring_file = FactoryBot.create(:tailoring_file)
    delete :destroy, :params => { :id => tailoring_file.id }, :session => set_session_user
    assert_response :ok
    refute ForemanOpenscap::ScapContent.exists?(tailoring_file.id)
  end
end
