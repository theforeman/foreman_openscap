require 'test_plugin_helper'

class HostExtensionsTest < ActiveSupport::TestCase
  setup do
    ForemanOpenscap::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
    @scap_content = FactoryGirl.create(:scap_content)
    @scap_content_profile = FactoryGirl.create(:scap_content_profile, :scap_content => @scap_content)
    @policy = FactoryGirl.create(:policy, :scap_content => @scap_content, :scap_content_profile => @scap_content_profile)
    @host = FactoryGirl.create(:compliance_host, :policies => [@policy])
  end

  test "should have download_path in enc without digest" do
    ForemanOpenscap::OpenscapProxyAssignedVersionCheck.any_instance.stubs(:openscap_proxy_versions).
      returns('test-proxy' => '0.5.4')
    enc_out = JSON.parse @host.policies_enc
    assert_equal 5, enc_out.first['download_path'].split('/').length
  end

  test "should have download_path in enc with digest" do
    ForemanOpenscap::OpenscapProxyAssignedVersionCheck.any_instance.stubs(:openscap_proxy_versions).
      returns({})
    enc_out = JSON.parse @host.policies_enc
    assert_equal 6, enc_out.first['download_path'].split('/').length
  end
end
