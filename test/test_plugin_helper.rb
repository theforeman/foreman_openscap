# This calls the main test_helper in Foreman-core
require 'test_helper'

# Add plugin to FactoryGirl's paths
FactoryGirl.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryGirl.reload

module ScapClientPuppetclass
  def skip_scap_callback
    Host::Managed.any_instance.stubs(:update_scap_client).returns(nil)
    Host::Managed.any_instance.stubs(:scap_client_class_present).returns(nil)
    Hostgroup.any_instance.stubs(:update_scap_client).returns(nil)
  end
end

module ScapTestProxy
  private

  def add_smart_proxy
    FactoryGirl.create(:smart_proxy, :url => 'http://localhost:8443', :features => [FactoryGirl.create(:feature, :name => 'Openscap')])
    ProxyAPI::Features.any_instance.stubs(:features).returns(%w(puppet openscap))
    versions = { "version" => "1.11.0", "modules" => { "openscap" => "0.5.3" } }
    ProxyAPI::Version.any_instance.stubs(:proxy_versions).returns(versions)
    ProxyAPI::Openscap.any_instance.stubs(:validate_scap_file).returns({'errors' => []})
    ProxyAPI::Openscap.any_instance.stubs(:fetch_policies_for_scap_content).
      returns({'xccdf_org.ssgproject.content_profile_common' => 'Common Profile for General-Purpose Fedora Systems'})
    ProxyAPI::Openscap.any_instance.stubs(:fetch_profiles_for_tailoring_file).
      returns({'xccdf_org.ssgproject.test_profile_common' => 'Stubbed test profile'})
  end
end

class ActionMailer::TestCase
  include ScapClientPuppetclass
  setup :skip_scap_callback
end

class ActionController::TestCase
  include ScapClientPuppetclass
  include ScapTestProxy

  setup :add_smart_proxy, :skip_scap_callback
end

class ActiveSupport::TestCase
  include ScapClientPuppetclass
  include ScapTestProxy

  setup :add_smart_proxy, :skip_scap_callback
end
