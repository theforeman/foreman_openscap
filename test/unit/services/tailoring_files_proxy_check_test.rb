require 'test_plugin_helper'

class TailoringFilesProxyCheckTest < ActiveSupport::TestCase
  test 'should find proxies with old versions' do
    ForemanOpenscap::OpenscapProxyVersionCheck.any_instance.stubs(:openscap_proxy_versions)
                                              .returns('old-proxy.test.com' => "0.5.4", "outdate-proxy.test.com" => "0.6.0")
    check = ForemanOpenscap::OpenscapProxyVersionCheck.new.run
    refute check.pass?
    refute check.message.empty?
  end

  test 'should not find any outdated proxies' do
    ForemanOpenscap::OpenscapProxyVersionCheck.any_instance.stubs(:openscap_proxy_versions)
                                              .returns({})
    check = ForemanOpenscap::OpenscapProxyVersionCheck.new.run
    assert check.pass?
    assert check.message.empty?
  end

  test 'should fail when proxy cannot be reached' do
    ProxyStatus::Version.any_instance.stubs(:version).raises(Foreman::WrappedException.new(nil, 'test message'))
    ForemanOpenscap::OpenscapProxyVersionCheck.any_instance.stubs(:get_openscap_proxies).returns([FactoryBot.create(:openscap_proxy)])
    check = ForemanOpenscap::OpenscapProxyVersionCheck.new.run
    refute check.pass?
    refute check.message.empty?
  end
end
