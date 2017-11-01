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
      assert_includes(scap_content.errors.messages[:base], 'No proxy with OpenSCAP feature was found.')
    end

    test 'proxy_url should return the first available proxy it finds' do
      available_proxy = SmartProxy.with_features('Openscap').first
      unavailable_proxy = FactoryBot.create(:smart_proxy, :url => 'http://proxy.example.com:8443', :features => [FactoryBot.create(:feature, :name => 'Openscap')])
      available_proxy.stubs(:proxy_url).returns(available_proxy.url)
      unavailable_proxy.stubs(:proxy_url).returns(nil)
      scap_content = ForemanOpenscap::ScapContent.new(:title => 'Fedora', :scap_file => @scap_file)
      assert_equal(available_proxy.url, scap_content.proxy_url)
    end
  end

  test 'should update profile title when fetching profiles from proxy' do
    scap_content = FactoryBot.create(:scap_content)
    scap_content.stubs(:fetch_profiles).returns({ "xccdf.test.profile" => "Changed title" })
    scap_profile = FactoryBot.create(:scap_content_profile, :scap_content => scap_content, :profile_id => 'xccdf.test.profile', :title => "Original title")
    scap_content.create_profiles
    assert_equal scap_profile.reload.title, 'Changed title'
  end

  test 'should create profile when fetching profiles from proxy' do
    scap_content = FactoryBot.create(:scap_content)
    scap_content.stubs(:fetch_profiles).returns({ "xccdf.test.profile" => "My title" })
    scap_content.create_profiles
    assert scap_content.reload.scap_content_profiles.where(:title => 'My title').first
  end
end
