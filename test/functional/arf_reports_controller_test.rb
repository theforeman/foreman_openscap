require 'test_plugin_helper'

class ArfReportsControllerTest < ActionController::TestCase

  test "should delete selected reports" do
    host = FactoryGirl.create(:compliance_host)
    openscap_proxy = ::ProxyAPI::Openscap.new(:url => "http://test.org:8080")
    ForemanOpenscap::Helper.stubs(:find_name_or_uuid_by_host)
    ::ProxyAPI::Openscap.any_instance.stubs(:destroy_report).returns(true)
    ForemanOpenscap::ArfReport.any_instance.stubs(:proxy).returns(openscap_proxy)
    arf_reports = []
    3.times do
      arf_reports << FactoryGirl.create(:arf_report, :host_id => host.id)
    end
    last_arf = arf_reports[-1]
    assert_difference("ForemanOpenscap::ArfReport.count", -2) do
      post :submit_delete_multiple, { :arf_report_ids => arf_reports[0..-2].map(&:id) }, set_session_user
    end
    assert_redirected_to arf_reports_path
    assert_equal last_arf, ForemanOpenscap::ArfReport.first
  end
end
