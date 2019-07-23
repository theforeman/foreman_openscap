require 'test_plugin_helper'

module ForemanOpenscap
  class ArfReportTest < ActiveSupport::TestCase
    setup do
      disable_orchestration
      User.current = users :admin
      ForemanOpenscap::Policy.any_instance.stubs(:ensure_needed_puppetclasses).returns(true)
      @policy = FactoryBot.create(:policy)
      @asset = FactoryBot.create(:asset)
      @host = FactoryBot.create(:compliance_host)
      @failed_source = FactoryBot.create(:source)
      @passed_source = FactoryBot.create(:source)

      @passed_log_params = { :result => "pass", :source => @passed_source }
      @failed_log_params = { :result => "fail", :source => @failed_source }
      @status = { :passed => 5, :failed => 1, :othered => 7 }.with_indifferent_access
    end

    test 'equal? should return true when there is no change in report results' do
      report_1 = FactoryBot.create(:arf_report, :policy => @policy, :host_id => @host.id)
      report_2 = FactoryBot.create(:arf_report, :policy => @policy, :host_id => @host.id)
      create_logs_for_report(report_1, [@passed_log_params, @failed_log_params])
      create_logs_for_report(report_2, [@passed_log_params, @failed_log_params])

      assert(report_1.equal?(report_2))
    end

    test 'equal? should return false when there is change in report results' do
      new_source = FactoryBot.create(:source)

      report_1 = FactoryBot.create(:arf_report, :policy => @policy, :host_id => @host.id)
      report_2 = FactoryBot.create(:arf_report, :policy => @policy, :host_id => @host.id)
      create_logs_for_report(report_1, [@passed_log_params, @failed_log_params])
      create_logs_for_report(report_2, [@passed_log_params, @passed_log_params])

      refute(report_1.equal?(report_2))
    end

    test 'equal? should return false when reports have different sets of rules' do
      report_1 = FactoryBot.create(:arf_report, :policy => @policy, :host_id => @host.id)
      report_2 = FactoryBot.create(:arf_report, :policy => @policy, :host_id => @host.id)
      create_logs_for_report(report_1, [@passed_log_params, @failed_log_params])
      create_logs_for_report(report_2, [@passed_log_params])

      refute(report_1.equal?(report_2))
    end

    test 'equal? should return false when reports have different hosts' do
      host = FactoryBot.create(:compliance_host)
      report_1 = FactoryBot.create(:arf_report, :policy => @policy, :host_id => @host.id)
      report_2 = FactoryBot.create(:arf_report, :policy => @policy, :host_id => host.id)
      create_logs_for_report(report_1, [@passed_log_params, @failed_log_params])
      create_logs_for_report(report_2, [@passed_log_params, @failed_log_params])

      refute(report_1.equal?(report_2))
    end

    test 'equal? should return false when reports have different policies' do
      policy = FactoryBot.create(:policy)
      report_1 = FactoryBot.create(:arf_report, :policy => @policy, :host_id => @host.id)
      report_2 = FactoryBot.create(:arf_report, :policy => policy, :host_id => @host.id)
      create_logs_for_report(report_1, [@passed_log_params, @failed_log_params])
      create_logs_for_report(report_2, [@passed_log_params, @failed_log_params])

      refute(report_1.equal?(report_2))
    end

    test 'should recognize report that failed' do
      report = FactoryBot.create(:arf_report, :host_id => @host.id, :status => @status)
      assert report.failed?
    end

    test 'should recognize report that othered' do
      @status[:failed] = 0
      report = FactoryBot.create(:arf_report, :host_id => @host.id, :status => @status)
      assert report.othered?
    end

    test 'should recognize report that passed' do
      @status[:failed] = 0
      @status[:othered] = 0
      report = FactoryBot.create(:arf_report, :host_id => @host.id, :status => @status)
      assert report.passed?
    end

    test 'should return latest report for each of the hosts' do
      reports = []
      host = FactoryBot.create(:compliance_host)
      5.times do
        reports << FactoryBot.create(:arf_report, :host_id => @host.id, :status => @status)
        FactoryBot.create(:policy_arf_report, :arf_report_id => reports.last.id)
        reports << FactoryBot.create(:arf_report, :host_id => host.id, :status => @status)
        FactoryBot.create(:policy_arf_report, :arf_report_id => reports.last.id)
      end
      assert ForemanOpenscap::ArfReport.latest.to_a.include? reports[-2]
      assert ForemanOpenscap::ArfReport.latest.to_a.include? reports[-1]
    end

    test 'should return latest report of policy for each of the hosts' do
      reports = []
      host = FactoryBot.create(:compliance_host)
      policy = FactoryBot.create(:policy)
      3.times do
        reports << FactoryBot.create(:arf_report, :host_id => @host.id, :status => @status)
        FactoryBot.create(:policy_arf_report, :arf_report_id => reports.last.id, :policy_id => @policy.id)

        reports << FactoryBot.create(:arf_report, :host_id => host.id, :status => @status)
        FactoryBot.create(:policy_arf_report, :arf_report_id => reports.last.id, :policy_id => @policy.id)

        reports << FactoryBot.create(:arf_report, :host_id => @host.id, :status => @status)
        FactoryBot.create(:policy_arf_report, :arf_report_id => reports.last.id, :policy_id => policy.id)

        reports << FactoryBot.create(:arf_report, :host_id => host.id, :status => @status)
        FactoryBot.create(:policy_arf_report, :arf_report_id => reports.last.id, :policy_id => policy.id)
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
        @passed_status = { :passed => 5, :failed => 0, :othered => 0 }.with_indifferent_access
        @othered_status = { :passed => 5, :failed => 0, :othered => 3 }.with_indifferent_access
        @failed_reports = []
        @othered_reports = []
        @passed_reports = []
        3.times do
          @failed_reports << FactoryBot.create(:arf_report, :host_id => @host.id, :status => @status)
          @passed_reports << FactoryBot.create(:arf_report, :host_id => @host.id, :status => @passed_status)
          @othered_reports << FactoryBot.create(:arf_report, :host_id => @host.id, :status => @othered_status)
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
      openscap_proxy_api = ::ProxyAPI::Openscap.new(:url => 'https://test-proxy.com:9090')
      openscap_proxy_api.stubs(:destroy_report).returns(true)
      ForemanOpenscap::Helper.stubs(:find_name_or_uuid_by_host).returns("abcde")
      ForemanOpenscap::ArfReport.any_instance.stubs(:openscap_proxy_api).returns(openscap_proxy_api)
      report = FactoryBot.create(:arf_report, :policy => @policy, :host_id => @host.id)
      create_logs_for_report(report, [@passed_log_params, @failed_log_params])

      report.destroy
      refute ForemanOpenscap::ArfReport.all.include? report
    end

    test 'should get reports by rule result' do
      rule_name = 'xccdf_org.something_installed'
      rule_names_1 = ['xccdf_org.something_tested', rule_name]
      rule_names_2 = ['xccdf_org.nothing', 'xccdf_org.whatever']
      rule_results_1 = ['fail', 'pass']
      rule_results_2 = ['fail', 'fail']
      host = FactoryBot.create(:compliance_host)
      report_1 = create_report_with_rules(host, rule_names_1, rule_results_1)
      report_2 = create_report_with_rules(host, rule_names_2, rule_results_2)
      res = ForemanOpenscap::ArfReport.by_rule_result(rule_name, 'pass').first
      assert_equal res, report_1
    end

    test 'should return same latest reports by scope and by association' do
      reports = []
      host = FactoryBot.create(:compliance_host)
      policy = FactoryBot.create(:policy)
      3.times do
        reports << FactoryBot.create(:arf_report, :host_id => @host.id, :status => @status)
        FactoryBot.create(:policy_arf_report, :arf_report_id => reports.last.id, :policy_id => @policy.id)

        reports << FactoryBot.create(:arf_report, :host_id => host.id, :status => @status)
        FactoryBot.create(:policy_arf_report, :arf_report_id => reports.last.id, :policy_id => @policy.id)

        reports << FactoryBot.create(:arf_report, :host_id => @host.id, :status => @status)
        FactoryBot.create(:policy_arf_report, :arf_report_id => reports.last.id, :policy_id => policy.id)

        reports << FactoryBot.create(:arf_report, :host_id => host.id, :status => @status)
        FactoryBot.create(:policy_arf_report, :arf_report_id => reports.last.id, :policy_id => policy.id)
      end

      assert_equal ForemanOpenscap::ArfReport.of_policy(policy).latest, policy.arf_reports.latest
    end

    private

    def create_logs_for_report(report, log_params)
      log_params.each do |param_group|
        FactoryBot.create(:compliance_log, param_group.merge(:report_id => report.id))
      end
    end
  end
end
