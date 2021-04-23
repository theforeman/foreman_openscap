require 'test_plugin_helper'

class OvalStatusTest < ActiveSupport::TestCase
  test 'should have no vulnerabilities' do
    host = FactoryBot.create(:oval_host)
    policy = FactoryBot.create(:oval_policy)
    FactoryBot.create(:oval_facet, :host => host, :oval_policies => [policy])

    status = ForemanOpenscap::OvalStatus.new
    status.host = host
    assert_equal 0, status.to_status
    assert_equal ::HostStatus::Global::OK, status.to_global
    assert status.relevant?
  end

  test 'should have vulnerabilities with available patch' do
    host = FactoryBot.create(:oval_host, :cves => [FactoryBot.create(:cve, :has_errata => false), FactoryBot.create(:cve, :has_errata => true)])
    policy = FactoryBot.create(:oval_policy)
    FactoryBot.create(:oval_facet, :host => host, :oval_policies => [policy])

    status = ForemanOpenscap::OvalStatus.new
    status.host = host
    assert_equal 2, status.to_status
    assert_equal ::HostStatus::Global::ERROR, status.to_global
    assert status.relevant?
  end

  test 'should have vulnerabilities without available patch' do
    host = FactoryBot.create(:oval_host, :cves => [FactoryBot.create(:cve, :has_errata => false), FactoryBot.create(:cve, :has_errata => false)])
    policy = FactoryBot.create(:oval_policy)
    FactoryBot.create(:oval_facet, :host => host, :oval_policies => [policy])

    status = ForemanOpenscap::OvalStatus.new
    status.host = host
    assert_equal 1, status.to_status
    assert_equal ::HostStatus::Global::WARN, status.to_global
    assert status.relevant?
  end

  test 'should not be relevant without oval policy' do
    host = FactoryBot.create(:oval_host, :cves => [FactoryBot.create(:cve)])
    status = ForemanOpenscap::OvalStatus.new
    status.host = host
    refute status.relevant?
  end
end
