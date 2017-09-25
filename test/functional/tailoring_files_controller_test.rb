require 'test_plugin_helper'

class TailoringFilesControllerTest < ActionController::TestCase
  setup do
    @tailoring_file = FactoryGirl.create(:tailoring_file)
    @scap_file = File.new("#{ForemanOpenscap::Engine.root}/test/files/tailoring_files/ssg-firefox-ds-tailoring.xml", 'rb')
  end

  test 'index' do
    get :index, {}, set_session_user
    assert_template 'index'
  end

  test 'new' do
    get :new, {}, set_session_user
    assert_template 'new'
  end

  test 'edit' do
    get :edit, { :id => @tailoring_file.id }, set_session_user
    assert_template 'edit'
  end

  test 'create' do
    uploaded_file = Rack::Test::UploadedFile.new(@scap_file, 'text/xml')
    # uploaded_file.original_filename = 'uploaded-tailoring-file.xml'
    post :create, { :tailoring_file => { :name => 'some_file', :scap_file => uploaded_file } }, set_session_user
    assert_redirected_to tailoring_files_url
  end

  test 'destroy' do
    tf = ForemanOpenscap::TailoringFile.first
    delete :destroy, { :id => tf.id }, set_session_user
    assert_redirected_to tailoring_files_url
    refute ForemanOpenscap::TailoringFile.exists?(tf.id)
  end
end
