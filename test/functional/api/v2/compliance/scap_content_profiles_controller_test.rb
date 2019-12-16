require 'test_plugin_helper'

class Api::V2::Compliance::ScapContentProfilesControllerTest < ActionController::TestCase
  test "should get index" do
    2.times do
      FactoryBot.create(:scap_content_profile)
    end
    FactoryBot.create(:scap_content, :scap_content_profiles => [ForemanOpenscap::ScapContentProfile.first])
    FactoryBot.create(:tailoring_file, :scap_content_profiles => [ForemanOpenscap::ScapContentProfile.last])
    get :index, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert response['results'].any?
    assert_response :success
  end
end
