require 'test_plugin_helper'

class OvalStatusTest < ActiveSupport::TestCase
  test 'should have no vulnerabilities' do
    host = FactoryBot.create(:oval_host)
    policy = FactoryBot.create(:oval_policy)
    FactoryBot.create(:oval_facet, :host => host, :oval_policies => [policy])

    status = ForemanOpenscap::OvalStatus.new
    status.host = host
    assert_equal 0, status.to_status
    assert status.relevant?
  end

  test 'should have vulnerabilities' do
    host = FactoryBot.create(:oval_host, :cves => [FactoryBot.create(:cve)])
    policy = FactoryBot.create(:oval_policy)
    FactoryBot.create(:oval_facet, :host => host, :oval_policies => [policy])

    status = ForemanOpenscap::OvalStatus.new
    status.host = host
    assert_equal 1, status.to_status
    assert status.relevant?
  end

  test 'should not be relevant without oval policy' do
    host = FactoryBot.create(:oval_host, :cves => [FactoryBot.create(:cve)])
    status = ForemanOpenscap::OvalStatus.new
    status.host = host
    refute status.relevant?
  end
end
