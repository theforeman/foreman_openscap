require 'test_plugin_helper'

module ForemanOpenscap
  class ArfReportTest < ActiveSupport::TestCase
    setup do
      disable_orchestration
      User.current = users :admin
      ForemanOpenscap::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
      @policy = FactoryGirl.create(:policy)
      @asset = FactoryGirl.create(:asset)
      @host = FactoryGirl.create(:compliance_host)
      @failed_source = FactoryGirl.create(:source)
      @passed_source = FactoryGirl.create(:source)
      @log_1 = FactoryGirl.create(:compliance_log, :result => "pass", :source => @passed_source)
      @log_2 = FactoryGirl.create(:compliance_log, :result => "fail", :source => @failed_source)
      @log_3 = FactoryGirl.create(:compliance_log, :result => "pass", :source => @passed_source)
      @status = {:passed => 5, :failed => 1, :othered => 7}.with_indifferent_access
    end

    test 'equal? should return true when there is no change in report results' do
      log_4 = FactoryGirl.create(:compliance_log, :result => "fail", :source => @failed_source)
      report_1 = FactoryGirl.create(:arf_report, :policy => @policy, :host_id => @host.id, :logs => [@log_1, @log_2])
      report_2 = FactoryGirl.create(:arf_report, :policy => @policy, :host_id => @host.id, :logs => [@log_3, log_4])

      assert(report_1.equal? report_2)
    end

    test 'equal? should return false when there is change in report results' do
      new_source = FactoryGirl.create(:source)
      log_4 = FactoryGirl.build(:compliance_log, :result => "pass", :source => new_source)
      report_1 = FactoryGirl.create(:arf_report, :policy => @policy, :host_id => @host.id, :logs => [@log_1, @log_2])
      report_2 = FactoryGirl.create(:arf_report, :policy => @policy, :host_id => @host.id, :logs => [@log_3, log_4])

      refute(report_1.equal? report_2)
    end

    test 'equal? should return false when reports have different sets of rules' do
      report_1 = FactoryGirl.create(:arf_report, :policy => @policy, :host_id => @host.id, :logs => [@log_1, @log_2])
      report_2 = FactoryGirl.create(:arf_report, :policy => @policy, :host_id => @host.id, :logs => [@log_3])

      refute(report_1.equal? report_2)
    end

    test 'equal? should return false when reports have different hosts' do
      host = FactoryGirl.create(:compliance_host)
      log_4 = FactoryGirl.create(:compliance_log, :result => "fail", :source => @failed_source)
      report_1 = FactoryGirl.create(:arf_report, :policy => @policy, :host_id => @host.id, :logs => [@log_1, @log_2])
      report_2 = FactoryGirl.create(:arf_report, :policy => @policy, :host_id => host.id, :logs => [@log_3, log_4])

      refute(report_1.equal? report_2)
    end

    test 'equal? should return false when reports have different policies' do
      policy = FactoryGirl.create(:policy)
      log_4 = FactoryGirl.create(:compliance_log, :result => "fail", :source => @failed_source)
      report_1 = FactoryGirl.create(:arf_report, :policy => @policy, :host_id => @host.id, :logs => [@log_1, @log_2])
      report_2 = FactoryGirl.create(:arf_report, :policy => policy, :host_id => @host.id, :logs => [@log_3, log_4])

      refute(report_1.equal? report_2)
    end

    test 'should recognize report that failed' do
      report = FactoryGirl.create(:arf_report, :host_id => @host.id, :status => @status)
      assert report.failed?
    end

    test 'should recognize report that othered' do
      @status[:failed] = 0
      report = FactoryGirl.create(:arf_report, :host_id => @host.id, :status => @status)
      assert report.othered?
    end

    test 'should recognize report that passed' do
      @status[:failed], @status[:othered] = 0, 0
      report = FactoryGirl.create(:arf_report, :host_id => @host.id, :status => @status)
      assert report.passed?
    end

    test 'should return latest report for each of the hosts' do
      reports = []
      host = FactoryGirl.create(:compliance_host)
      5.times do
        reports << FactoryGirl.create(:arf_report, :host_id => @host.id, :status => @status)
        FactoryGirl.create(:policy_arf_report, :arf_report_id => reports.last.id)
        reports << FactoryGirl.create(:arf_report, :host_id => host.id, :status => @status)
        FactoryGirl.create(:policy_arf_report, :arf_report_id => reports.last.id)
      end
      assert ForemanOpenscap::ArfReport.latest.include? reports[-2]
      assert ForemanOpenscap::ArfReport.latest.include? reports[-1]
    end

    test 'should return latest report of policy for each of the hosts' do
      reports = []
      host = FactoryGirl.create(:compliance_host)
      policy = FactoryGirl.create(:policy)
      3.times do
        reports << FactoryGirl.create(:arf_report, :host_id => @host.id, :status => @status)
        FactoryGirl.create(:policy_arf_report, :arf_report_id => reports.last.id, :policy_id => @policy.id)

        reports << FactoryGirl.create(:arf_report, :host_id => host.id, :status => @status)
        FactoryGirl.create(:policy_arf_report, :arf_report_id => reports.last.id, :policy_id => @policy.id)

        reports << FactoryGirl.create(:arf_report, :host_id => @host.id, :status => @status)
        FactoryGirl.create(:policy_arf_report, :arf_report_id => reports.last.id, :policy_id => policy.id)

        reports << FactoryGirl.create(:arf_report, :host_id => host.id, :status => @status)
        FactoryGirl.create(:policy_arf_report, :arf_report_id => reports.last.id, :policy_id => policy.id)
      end

      assert ForemanOpenscap::ArfReport.latest_of_policy(policy).include? reports[-1]
      assert ForemanOpenscap::ArfReport.latest_of_policy(policy).include? reports[-2]
      assert ForemanOpenscap::ArfReport.latest_of_policy(@policy).include? reports[-3]
      assert ForemanOpenscap::ArfReport.latest_of_policy(@policy).include? reports[-4]
      assert_equal 2, ForemanOpenscap::ArfReport.latest_of_policy(@policy).count
      assert_equal 2, ForemanOpenscap::ArfReport.latest_of_policy(policy).count
    end

    context 'retrieving reports by status' do
      setup do
        @passed_status = {:passed => 5, :failed => 0, :othered => 0}.with_indifferent_access
        @othered_status = {:passed => 5, :failed => 0, :othered => 3}.with_indifferent_access
        @failed_reports = []
        @othered_reports = []
        @passed_reports = []
        3.times do
          @failed_reports << FactoryGirl.create(:arf_report, :host_id => @host.id, :status => @status)
          @passed_reports << FactoryGirl.create(:arf_report, :host_id => @host.id, :status => @passed_status)
          @othered_reports << FactoryGirl.create(:arf_report, :host_id => @host.id, :status => @othered_status)
        end
      end

      test 'should return failed reports' do
        assert_equal 3, ForemanOpenscap::ArfReport.failed.count
        @failed_reports.each { |failure| assert ForemanOpenscap::ArfReport.failed.include?(failure) }
      end

      test 'should return othered reports' do
        assert_equal 3, ForemanOpenscap::ArfReport.othered.count
        @othered_reports.each { |other| assert ForemanOpenscap::ArfReport.othered.include?(other) }
      end

      test 'should return passed reports' do
        assert_equal 3, ForemanOpenscap::ArfReport.passed.count
        @passed_reports.each { |pass| assert ForemanOpenscap::ArfReport.passed.include?(pass) }
      end
    end

    test 'should destroy report' do
      proxy = ::ProxyAPI::Openscap.new(:url => 'https://test-proxy.com:9090')
      proxy.stubs(:destroy_report).returns(true)
      ForemanOpenscap::Helper.stubs(:find_name_or_uuid_by_host).returns("abcde")
      ForemanOpenscap::ArfReport.any_instance.stubs(:proxy).returns(proxy)
      report = FactoryGirl.create(:arf_report, :policy => @policy, :host_id => @host.id, :logs => [@log_1, @log_2])
      report.destroy
      refute ForemanOpenscap::ArfReport.all.include? report
    end
  end
end
