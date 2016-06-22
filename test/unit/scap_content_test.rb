require 'test_plugin_helper'

class ScapContentTest < ActiveSupport::TestCase
  setup do
    @scap_file = File.new("#{ForemanOpenscap::Engine.root}/test/files/scap_contents/ssg-fedora-ds.xml", 'rb').read
  end
  context 'validate scap contents' do
    test 'create scap content' do
      scap_content = ForemanOpenscap::ScapContent.new(:title => 'Fedora', :scap_file => @scap_file)
      assert(scap_content.valid?)
    end

    test 'should not allow title.length > 255' do
      scap_content = ForemanOpenscap::ScapContent.new(:title => ("a" * 256), :scap_file => @scap_file)
      refute(scap_content.valid?)
    end

    test 'scap content should fail if no openscap proxy' do
      SmartProxy.stubs(:with_features).returns([])
      ProxyAPI::AvailableProxy.any_instance.stubs(:available?).returns(false)
      scap_content = ForemanOpenscap::ScapContent.new(:title => 'Fedora', :scap_file => @scap_file)
      refute(scap_content.save)
      assert_includes(scap_content.errors.messages[:base], 'No proxy with OpenSCAP features')
    end

    test 'proxy_url should return the first available proxy it finds' do
      available_proxy = SmartProxy.with_features('Openscap').first
      unavailable_proxy = FactoryGirl.create(:smart_proxy, :url => 'http://proxy.example.com:8443', :features => [FactoryGirl.create(:feature, :name => 'Openscap')])
      proxy1_url = ProxyAPI::AvailableProxy.new(:url => available_proxy.url)
      proxy2_url = ProxyAPI::AvailableProxy.new(:url => unavailable_proxy.url)
      proxy1_url.stubs(:available?).returns(available_proxy.url)
      proxy2_url.stubs(:available?).returns(false)
      scap_content = ForemanOpenscap::ScapContent.new(:title => 'Fedora', :scap_file => @scap_file)
      assert_equal(available_proxy.url, scap_content.proxy_url)
    end
  end
end
