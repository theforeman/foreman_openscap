# This calls the main test_helper in Foreman-core
require 'test_helper'

# Add plugin to FactoryBot's paths
FactoryBot.definition_file_paths << File.join(File.dirname(__FILE__), 'factories')
# Add factories from foreman_ansible
FactoryBot.definition_file_paths << File.join(ForemanAnsible::Engine.root, '/test/factories')
FactoryBot.definition_file_paths << File.join(ForemanPuppet::Engine.root, '/test/factories')
FactoryBot.reload

require "#{ForemanOpenscap::Engine.root}/test/fixtures/cve_fixtures"

module ScapClientPuppetclass
  def setup_puppet_class
    puppet_config = ::ForemanOpenscap::ClientConfig::Puppet.new
    ForemanPuppet::Puppetclass.find_by(:name => puppet_config.puppetclass_name)&.destroy

    puppet_class = FactoryBot.create(:puppetclass, :name => puppet_config.puppetclass_name)
    server_param = FactoryBot.create(:puppetclass_lookup_key, :key => puppet_config.server_param, :default_value => nil, :override => false)
    port_param = FactoryBot.create(:puppetclass_lookup_key, :key => puppet_config.port_param, :default_value => nil, :override => false)
    policies_param = FactoryBot.create(:puppetclass_lookup_key, :key => puppet_config.policies_param, :default_value => nil, :override => false)

    env = FactoryBot.create :environment

    FactoryBot.create(:environment_class,
                      :puppetclass_id => puppet_class.id,
                      :environment_id => env.id,
                      :puppetclass_lookup_key_id => server_param.id)
    FactoryBot.create(:environment_class,
                      :puppetclass_id => puppet_class.id,
                      :environment_id => env.id,
                      :puppetclass_lookup_key_id => port_param.id)
    FactoryBot.create(:environment_class,
                      :puppetclass_id => puppet_class.id,
                      :environment_id => env.id,
                      :puppetclass_lookup_key_id => policies_param.id)
    { :puppet_class => puppet_class, :env => env, :server_param => server_param, :port_param => port_param, :policies_param => policies_param }
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
    metrics = {
      'passed' => rule_results.count { |result| result == 'pass' },
      'failed' => rule_results.count { |result| result == 'fail' },
      'othered' => rule_results.reject { |result| result == 'fail' || result == 'pass' }.count
    }
    report = FactoryBot.create(:arf_report, :host_id => host.id, :metrics => metrics, :status => metrics)
    body = []
    rule_names.each_with_index do |item, index|
      body << [rule_names[index], rule_results[index], 1]
    end
    report.body = body.to_json
    report.digest = ForemanOpenscap::ArfReport.calculate_digest(body)
    report.save
    report
  end
end

class ActionMailer::TestCase
  include ScapClientPuppetclass
end

class ActionController::TestCase
  include ScapClientPuppetclass
  include ScapTestProxy
  include ScapTestCommon

  setup :add_smart_proxy
end

class ActiveSupport::TestCase
  include ScapClientPuppetclass
  include ScapTestProxy
  include ScapTestCommon

  setup :add_smart_proxy
end
