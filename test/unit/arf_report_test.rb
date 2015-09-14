require 'test_plugin_helper'

module ForemanOpenscap
  class ArfReportTest < ActiveSupport::TestCase
    setup do
      disable_orchestration
      User.current = users :admin
      ForemanOpenscap::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
      @policy = FactoryGirl.create(:policy)
      @asset = FactoryGirl.create(:asset)
      @result_1 = FactoryGirl.build(:xccdf_rule_result, :xccdf_result_id => 1, :xccdf_rule_id => 1)
      @result_2 = FactoryGirl.build(:xccdf_rule_result, :xccdf_result_id => 2, :xccdf_rule_id => 2)
      @result_3 = FactoryGirl.build(:xccdf_rule_result, :xccdf_result_id => 1, :xccdf_rule_id => 1)
    end

    test 'equal? should return true when there is no change in report results' do
      result_4 = FactoryGirl.build(:xccdf_rule_result, :xccdf_result_id => 2, :xccdf_rule_id => 2)
      report_1 = FactoryGirl.create(:arf_report, :policy => @policy, :asset => @asset, :xccdf_rule_results => [@result_1, @result_2])
      report_2 = FactoryGirl.create(:arf_report, :policy => @policy, :asset => @asset, :xccdf_rule_results => [@result_3, result_4])

      assert(report_1.equal? report_2)
    end

    test 'equal? should return false when there is change in report results' do
      result_4 = FactoryGirl.build(:xccdf_rule_result, :xccdf_result_id => 2, :xccdf_rule_id => 6)
      report_1 = FactoryGirl.create(:arf_report, :policy => @policy, :asset => @asset, :xccdf_rule_results => [@result_1, @result_2])
      report_2 = FactoryGirl.create(:arf_report, :policy => @policy, :asset => @asset, :xccdf_rule_results => [@result_3, result_4])

      refute(report_1.equal? report_2)
    end

    test 'equal? should return false when reports have different sets of rules' do
      report_1 = FactoryGirl.create(:arf_report, :policy => @policy, :asset => @asset, :xccdf_rule_results => [@result_1, @result_2])
      report_2 = FactoryGirl.create(:arf_report, :policy => @policy, :asset => @asset, :xccdf_rule_results => [@result_3])

      refute(report_1.equal? report_2)
    end

    test 'equal? should return false when reports have different assets' do
      asset = FactoryGirl.create(:asset)
      result_4 = FactoryGirl.build(:xccdf_rule_result, :xccdf_result_id => 2, :xccdf_rule_id => 2)
      report_1 = FactoryGirl.create(:arf_report, :policy => @policy, :asset => @asset, :xccdf_rule_results => [@result_1, @result_2])
      report_2 = FactoryGirl.create(:arf_report, :policy => @policy, :asset => asset, :xccdf_rule_results => [@result_3, result_4])

      refute(report_1.equal? report_2)
    end

    test 'equal? should return false when reports have different policies' do
      policy = FactoryGirl.create(:policy)
      result_4 = FactoryGirl.build(:xccdf_rule_result, :xccdf_result_id => 2, :xccdf_rule_id => 2)
      report_1 = FactoryGirl.create(:arf_report, :policy => @policy, :asset => @asset, :xccdf_rule_results => [@result_1, @result_2])
      report_2 = FactoryGirl.create(:arf_report, :policy => policy, :asset => @asset, :xccdf_rule_results => [@result_3, result_4])

      refute(report_1.equal? report_2)
    end

    test 'should recognize report that failed' do
      breakdown = FactoryGirl.build(:arf_report_breakdown, :passed => 1, :failed => 1, :othered => 1)
      report = FactoryGirl.create(:arf_report, :arf_report_breakdown => breakdown)
      assert report.failed?
    end

    test 'should recognize report that othered' do
      breakdown = FactoryGirl.build(:arf_report_breakdown, :passed => 1, :failed => 0, :othered => 1)
      report = FactoryGirl.create(:arf_report, :arf_report_breakdown => breakdown)
      assert report.othered?
    end

    test 'should recognize report that passed' do
      breakdown = FactoryGirl.build(:arf_report_breakdown, :passed => 1, :failed => 0, :othered => 0)
      report = FactoryGirl.create(:arf_report, :arf_report_breakdown => breakdown)
      assert report.passed?
    end
  end
end
