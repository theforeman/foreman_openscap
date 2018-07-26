# This calls the main test_helper in Foreman-core
require 'test_helper'

# Add plugin to FactoryBot's paths
FactoryBot.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
FactoryBot.reload

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
    FactoryBot.create(:smart_proxy, :url => 'http://localhost:8443', :features => [FactoryBot.create(:feature, :name => 'Openscap')])
    ProxyAPI::Features.any_instance.stubs(:features).returns(%w[puppet openscap])
    versions = { "version" => "1.11.0", "modules" => { "openscap" => "0.5.3" } }
    ProxyAPI::Version.any_instance.stubs(:proxy_versions).returns(versions)
    ProxyAPI::Openscap.any_instance.stubs(:validate_scap_file).returns({ 'errors' => [] })
    ProxyAPI::Openscap.any_instance.stubs(:fetch_policies_for_scap_content)
                      .returns({ 'xccdf_org.ssgproject.content_profile_common' => 'Common Profile for General-Purpose Fedora Systems' })
    ProxyAPI::Openscap.any_instance.stubs(:fetch_profiles_for_tailoring_file)
                      .returns({ 'xccdf_org.ssgproject.test_profile_common' => 'Stubbed test profile' })
  end
end

module ScapTestCommon
  private

  def create_report_with_rules(host, rule_names, rule_results)
    raise "rule_names and rule_results should have the same length!" if rule_names.size != rule_results.size
    report = FactoryBot.create(:arf_report, :host_id => host.id)
    rule_names.each_with_index do |item, index|
      source = FactoryBot.create(:compliance_source, :value => rule_names[index])
      log = FactoryBot.create(:compliance_log, :source => source, :report => report, :result => rule_results[index])
    end
    report
  end
end

class ActionMailer::TestCase
  include ScapClientPuppetclass
  setup :skip_scap_callback
end

class ActionController::TestCase
  include ScapClientPuppetclass
  include ScapTestProxy
  include ScapTestCommon

  setup :add_smart_proxy, :skip_scap_callback
end

class ActiveSupport::TestCase
  include ScapClientPuppetclass
  include ScapTestProxy
  include ScapTestCommon

  setup :add_smart_proxy, :skip_scap_callback
end
