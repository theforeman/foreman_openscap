require 'test_plugin_helper'

class Api::V2::Compliance::TailoringFilesControllerTest < ActionController::TestCase
  test "should get index" do
    FactoryGirl.create(:tailoring_file)
    get :index, {}, set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['results'].any?
    assert_response :success
  end

  test "should return xml of tailoring_file" do
    tailoring_file = FactoryGirl.create(:tailoring_file)
    get :show, { :id => tailoring_file.id }, set_session_user
    assert(@response.header['Content-Type'], 'application/xml')
    assert_response :success
  end

  test "should not create invalid tailoring_file" do
    post :create, {}, set_session_user
    assert_response :unprocessable_entity
  end

  test "should create tailoring_file" do
    tf = FactoryGirl.build(:tailoring_file)
    tf_params = { :name => tf.name, :original_filename => tf.original_filename, :scap_file => tf.scap_file }
    ForemanOpenscap::OpenscapProxyVersionCheck.any_instance.stubs(:openscap_proxy_versions)
                                              .returns({})
    post :create, tf_params, set_session_user
    assert_response :success
  end

  test "should update tailoring_file" do
    tailoring_file = FactoryGirl.create(:tailoring_file)
    put :update, { :id => tailoring_file.id, :tailoring_file => { :name => 'RHEL7 SCAP' } }, set_session_user
    assert_response :success
    assert tailoring_file.name, 'RHEL7 SCAP'
  end

  test "should not update invalid tailoring_file" do
    tailoring_file = FactoryGirl.create(:tailoring_file)
    ProxyAPI::Openscap.any_instance.stubs(:validate_scap_file).returns({ 'errors' => ['Invalid file'] })
    put :update, { :id => tailoring_file.id, :tailoring_file => { :scap_file => '<xml>blah</xml>' } }, set_session_user
    assert_response :unprocessable_entity
  end

  test "should destory tailoring_file" do
    tailoring_file = FactoryGirl.create(:tailoring_file)
    delete :destroy, { :id => tailoring_file.id }, set_session_user
    assert_response :ok
    refute ForemanOpenscap::ScapContent.exists?(tailoring_file.id)
  end

  test "should not create tailoring file when there is outdated proxy version" do
    tf = FactoryGirl.build(:tailoring_file)
    tf_params = { :name => tf.name, :original_filename => tf.original_filename, :scap_file => tf.scap_file }
    ForemanOpenscap::OpenscapProxyVersionCheck.any_instance.stubs(:openscap_proxy_versions)
                                              .returns('test-proxy' => '0.5.4')
    post :create, tf_params, set_session_user
    assert_response :unprocessable_entity
  end
end
