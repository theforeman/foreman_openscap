require 'test_plugin_helper'

class OpenscapProxyExtensionsTest < ActiveSupport::TestCase

  setup do
    @host = FactoryGirl.create(:compliance_host)
  end

  test "should return proxy api for openscap" do
    arf = FactoryGirl.create(:arf_report,
                             :host_id => @host.id,
                             :openscap_proxy => @host.openscap_proxy)
    api = arf.openscap_proxy_api
    assert_equal (@host.openscap_proxy.url + "/compliance/"), api.url
  end

  test "should raise exception when no openscap proxy asociated" do
    arf = FactoryGirl.create(:arf_report, :host_id => @host.id)
    assert_raises(Foreman::Exception) { arf.openscap_proxy_api }
  end
end
