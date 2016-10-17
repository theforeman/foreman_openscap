require 'test_plugin_helper'
require 'tmpdir'

class Api::V2::Compliance::ArfReportsControllerTest < ActionController::TestCase
  setup do
    # override validation of policy (puppetclass, lookup_key overrides)
    ForemanOpenscap::Policy.any_instance.stubs(:valid?).returns(true)
    @host = FactoryGirl.create(:compliance_host)
    @report = FactoryGirl.create(:arf_report,
                                 :host_id => @host.id,
                                 :openscap_proxy => FactoryGirl.create(:smart_proxy, :url => "http://smart-proxy.org:8000"))
  end
  test "should get index" do
    get :index, {}, set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert_not response['results'].empty?
    assert_response :success
  end

  test "should get show" do
    get :show, { :id => @report.to_param }, set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    refute response['passed'].blank?
    refute response['failed'].blank?
    refute response['othered'].blank?
    assert_response :success
  end

  test "should download report" do
    bzipped_report = File.open "#{ForemanOpenscap::Engine.root}/test/files/arf_report/arf_report.bz2", &:read
    ForemanOpenscap::ArfReport.any_instance.stubs(:to_bzip).returns(bzipped_report)
    get :download, { :id => @report.to_param }, set_session_user
    t = Tempfile.new('tmp_report')
    t.write @response.body
    t.close
    refute t.size.zero?
  end
end
