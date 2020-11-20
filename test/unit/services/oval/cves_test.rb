require 'test_plugin_helper'

class ForemanOpenscap::Oval::CvesTest < ActiveSupport::TestCase
  setup do
    @fxs = ForemanOpenscap::CveFixtures.new
    @instance = ForemanOpenscap::Oval::Cves.new
  end

  test "should add CVEs to host" do
    oval_data = create_cve_data @fxs.one
    host = FactoryBot.create(:host)
    assert_empty host.cves
    @instance.create host, oval_data
    refute_empty host.cves

    assert_equal host.cves, host.cves.distinct
  end

  test "should filter out CVEs that do not affect the host" do
    oval_data = create_cve_data @fxs.two
    host = FactoryBot.create(:host)
    assert_empty host.cves
    @instance.create host, oval_data
    refute_empty host.cves

    assert_equal host.cves, ForemanOpenscap::Cve.where(:ref_id => @fxs.ids_from(@fxs.res_two))
  end

  test "should update host with a new set of CVEs" do
    oval_data = create_cve_data @fxs.one
    host = FactoryBot.create(:host)
    assert_empty host.cves
    @instance.create host, oval_data
    refute_empty host.cves

    cve_ids_before = host.reload.cve_ids
    oval_data = create_cve_data @fxs.two
    @instance.create host, oval_data

    refute_equal host.cve_ids, cve_ids_before
    assert_equal host.cves, ForemanOpenscap::Cve.where(:ref_id => @fxs.ids_from(@fxs.res_two))

    @fxs.ids_from(@fxs.res_three).map do |ref_id|
      refute ForemanOpenscap::Cve.find_by :ref_id => ref_id
    end
  end

  test "should not delete CVEs associated to another host" do
    oval_data = create_cve_data @fxs.one
    host = FactoryBot.create(:host)
    @instance.create host, oval_data
    refute_empty host.cves

    cves_before = host.reload.cves

    oval_data_2 = create_cve_data @fxs.two
    host_2 = FactoryBot.create(:host)
    @instance.create host_2, oval_data_2

    assert_equal host.reload.cves, cves_before
  end

  def create_cve_data(fixture)
    { 'oval_results' => fixture }
  end
end
