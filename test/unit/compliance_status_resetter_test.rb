require 'test_plugin_helper'

class ComplianceStatusResetterTest < ActiveSupport::TestCase
  setup do
    ForemanOpenscap::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
    @policy = FactoryBot.create(:policy)
  end

  test 'creates inconclusive status for host without existing status' do
    host = FactoryBot.create(:compliance_host, :policies => [@policy])

    ForemanOpenscap::ComplianceStatusResetter.to_inconclusive([host.id])

    assert_equal ForemanOpenscap::ComplianceStatus::INCONCLUSIVE, host.reload.compliance_status
  end

  test 'resets existing compliant status to inconclusive' do
    host = FactoryBot.create(:compliance_host, :policies => [@policy])
    set_compliance_status(host, ForemanOpenscap::ComplianceStatus::COMPLIANT)

    ForemanOpenscap::ComplianceStatusResetter.to_inconclusive([host.id])

    assert_equal ForemanOpenscap::ComplianceStatus::INCONCLUSIVE, host.reload.compliance_status
  end

  test 'ignores blank and duplicate host ids without error' do
    host = FactoryBot.create(:compliance_host, :policies => [@policy])

    ForemanOpenscap::ComplianceStatusResetter.to_inconclusive([host.id, host.id, nil])

    assert_equal ForemanOpenscap::ComplianceStatus::INCONCLUSIVE, host.reload.compliance_status
  end

  test 'does nothing for an empty list of host ids' do
    assert_nil ForemanOpenscap::ComplianceStatusResetter.to_inconclusive([])
  end

  test 'refreshes host global_status so it reflects the new inconclusive compliance status' do
    host = FactoryBot.create(:compliance_host, :policies => [@policy])
    set_compliance_status(host, ForemanOpenscap::ComplianceStatus::COMPLIANT)
    host.refresh_global_status!
    assert_equal ::HostStatus::Global::OK, host.reload.global_status

    ForemanOpenscap::ComplianceStatusResetter.to_inconclusive([host.id])

    assert_equal ::HostStatus::Global::WARN, host.reload.global_status
  end
end
