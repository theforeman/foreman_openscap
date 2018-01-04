require 'test_plugin_helper'

class TailoringFilesControllerTest < ActionController::TestCase
  setup do
    @tailoring_file = FactoryBot.create(:tailoring_file)
    @scap_file = File.new("#{ForemanOpenscap::Engine.root}/test/files/tailoring_files/ssg-firefox-ds-tailoring.xml", 'rb')
  end

  test 'index' do
    get :index, :session => set_session_user
    assert_template 'index'
  end

  test 'new' do
    get :new, :session => set_session_user
    assert_template 'new'
  end

  test 'edit' do
    get :edit, :params => { :id => @tailoring_file.id }, :session => set_session_user
    assert_template 'edit'
  end

  test 'create' do
    uploaded_file = Rack::Test::UploadedFile.new(@scap_file, 'text/xml', :original_filename => 'uploaded_tailoring.file')
    # uploaded_file.original_filename = 'uploaded-tailoring-file.xml'
    post :create, :params => { :tailoring_file => { :name => 'some_file', :scap_file => uploaded_file } }, :session => set_session_user
    assert_redirected_to tailoring_files_url
  end

  test 'destroy' do
    tf = ForemanOpenscap::TailoringFile.first
    delete :destroy, :params => { :id => tf.id }, :session => set_session_user
    assert_redirected_to tailoring_files_url
    refute ForemanOpenscap::TailoringFile.exists?(tf.id)
  end
end
