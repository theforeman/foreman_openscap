require 'test_plugin_helper'
require 'tmpdir'

class Api::V2::Compliance::ArfReportsControllerTest < ActionController::TestCase
  setup do
    # required for mysql where database cleaner does not cleanup things properly
    # because of arf_create does explicit transaction commit
    Message.delete_all
    # override validation of policy (puppetclass, lookup_key overrides)
    ForemanOpenscap::Policy.any_instance.stubs(:valid?).returns(true)
    @host = FactoryBot.create(:compliance_host)
    @policy = FactoryBot.create(:policy)
    @asset = FactoryBot.create(:asset, :assetable_id => @host.id)

    @from_json = arf_from_json "#{ForemanOpenscap::Engine.root}/test/files/arf_report/arf_report.json"
    @cname = '9521a5c5-8f44-495f-b087-20e86b30bf67'
    @proxy = FactoryBot.create(:smart_proxy, :url => "http://smart-proxy.org:8000", :name => 'smart_proxy_with_openscap')
  end

  test "should get index" do
    create_arf_report
    get :index, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert_not response['results'].empty?
    assert_response :success
  end

  test "should get show" do
    report = create_arf_report
    get :show, :params => { :id => report.to_param }, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    refute response['passed'].blank?
    refute response['failed'].blank?
    refute response['othered'].blank?
    assert_response :success
  end

  test "should download report" do
    report = create_arf_report
    bzipped_report = File.read "#{ForemanOpenscap::Engine.root}/test/files/arf_report/arf_report.bz2"
    ForemanOpenscap::ArfReport.any_instance.stubs(:to_bzip).returns(bzipped_report)
    get :download, :params => { :id => report.to_param }, :session => set_session_user
    t = Tempfile.new('tmp_report')
    t.write @response.body
    t.close
    refute t.size.zero?
  end

  test "should create report using proxy name" do
    reports_cleanup
    date = Time.new(1984, 9, 15)
    ForemanOpenscap::Helper.stubs(:get_asset).returns(@asset)
    post :create,
         :params => @from_json.merge(:cname => @cname,
                                     :policy_id => @policy.id,
                                     :date => date.to_i,
                                     :openscap_proxy_name => @proxy.name),
         :session => set_session_user
    report = ForemanOpenscap::ArfReport.unscoped.last
    assert_equal date, report.reported_at
    report_logs = report.logs
    msg_count = report_logs.flat_map(&:message).count
    src_count = report_logs.flat_map(&:source).count
    assert(msg_count > 0)
    assert_equal msg_count, src_count
  end

  test "should create report using proxy url" do
    reports_cleanup
    date = Time.new(1984, 9, 15)
    ForemanOpenscap::Helper.stubs(:get_asset).returns(@asset)
    post :create,
         :params => @from_json.merge(:cname => @cname,
                                     :policy_id => @policy.id,
                                     :date => date.to_i,
                                     :openscap_proxy_url => @proxy.url),
         :session => set_session_user
    assert_response :success
  end

  test "should not create report when no proxy params present" do
    asset = FactoryBot.create(:asset)
    date = Time.new(1944, 6, 6)
    ForemanOpenscap::Helper.stubs(:get_asset).returns(asset)
    post :create,
         :params => @from_json.merge(:cname => @cname,
                                     :policy_id => @policy.id,
                                     :date => date.to_i),
         :session => set_session_user
    assert_response :unprocessable_entity
    res = JSON.parse(@response.body)
    msg = "Failed to upload Arf Report, OpenSCAP proxy name or url not found in params when uploading for #{asset.host.name} and host is missing openscap_proxy"
    assert_equal msg, res["result"]
  end

  test "should not duplicate messages" do
    dates = [Time.new(1984, 9, 15), Time.new(1932, 3, 27)]
    params = @from_json.with_indifferent_access.merge(:cname => @cname,
                                                      :policy_id => @policy.id,
                                                      :date => dates[0].to_i)
    assert ForemanOpenscap::ArfReport.create_arf(@asset, @proxy, params)

    ForemanOpenscap::Helper.stubs(:get_asset).returns(@asset)
    post :create,
         :params => @from_json.merge(:cname => @cname,
                                     :policy_id => @policy.id,
                                     :date => dates[1].to_i,
                                     :openscap_proxy_name => @proxy.name),
         :session => set_session_user
    assert_equal Message.where(:digest => ForemanOpenscap::ArfReport.unscoped.last.logs.first.message.digest).count, 1
  end

  test "should recognize changes in messages" do
    params = @from_json.with_indifferent_access.merge(:cname => @cname,
                                                      :policy_id => @policy.id,
                                                      :date => Time.new(2017, 5, 6).to_i)
    assert ForemanOpenscap::ArfReport.create_arf(@asset, @proxy, params)

    ForemanOpenscap::Helper.stubs(:get_asset).returns(@asset)
    changed_from_json = arf_from_json "#{ForemanOpenscap::Engine.root}/test/files/arf_report/arf_report_msg_desc_changed.json"
    post :create,
         :params => changed_from_json.merge(:cname => @cname,
                                            :policy_id => @policy.id,
                                            :date => Time.new(2017, 6, 6).to_i,
                                            :openscap_proxy_name => @proxy.name),
         :session => set_session_user

    assert_response :success

    src_ids = Source.where(:value => "xccdf_org.ssgproject.content_rule_firefox_preferences-lock_settings_obscure").pluck(:id)
    msgs = Log.where(:source_id => src_ids).map(&:message)
    assert_equal 2, msgs.count
    msg_a, msg_b = msgs.sort_by(&:id)
    assert_equal msg_a.description, msg_b.description
    assert_equal "Disable ROT-13 encoding by setting general.config.obscure_value\nto 42, not 0 as before.", msg_a.description
  end

  test "should recognize change in message title/value" do
    reports_cleanup
    params = @from_json.with_indifferent_access.merge(:cname => @cname,
                                                      :policy_id => @policy.id,
                                                      :date => Time.new(2017, 7, 6).to_i)
    assert ForemanOpenscap::ArfReport.create_arf(@asset, @proxy, params)

    ForemanOpenscap::Helper.stubs(:get_asset).returns(@asset)
    changed_from_json = arf_from_json "#{ForemanOpenscap::Engine.root}/test/files/arf_report/arf_report_msg_value_changed.json"
    post :create,
         :params => changed_from_json.merge(:cname => @cname,
                                 :policy_id => @policy.id,
                                 :date => Time.new(2017, 8, 6).to_i,
                                 :openscap_proxy_name => @proxy.name),
         :session => set_session_user

    assert_response :success

    reports = ForemanOpenscap::ArfReport.unscoped.all
    assert_equal reports.count, 2

    new_msgs = Message.where(:value => "Disable Firefox Configuration File ROT-13 Encoding Changed For Test")
    old_msgs = Message.where(:value => "Disable Firefox Configuration File ROT-13 Encoding")
    assert_equal new_msgs.count, 1
    assert_equal old_msgs.count, 0
    assert_equal new_msgs.first.digest, Digest::SHA1.hexdigest("Disable Firefox Configuration File ROT-13 Encoding Changed For Test")
  end

  test "should find reports by policy name" do
    reports_cleanup
    report_a = create_arf_report
    report_b = create_arf_report
    policy = FactoryBot.create(:policy)
    FactoryBot.create(:policy_arf_report, :policy_id => @policy.id, :arf_report_id => report_a.id)
    FactoryBot.create(:policy_arf_report, :policy_id => policy.id, :arf_report_id => report_b.id)

    get :index, :params => { :search => "compliance_policy=#{policy.name}" }, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
    assert_equal 1, response['results'].count
  end

  test "should find reports compliant with policy" do
    reports_cleanup
    policy = FactoryBot.create(:policy)
    create_arf_report_for_search({ "passed" => 1, "othered" => 2, "failed" => 3 }, @policy)
    create_arf_report_for_search({ "passed" => 1, "othered" => 0, "failed" => 0 }, @policy)
    create_arf_report_for_search({ "passed" => 1, "othered" => 2, "failed" => 0 }, @policy)
    create_arf_report_for_search({ "passed" => 3, "othered" => 0, "failed" => 0 }, @policy)
    create_arf_report_for_search({ "passed" => 5, "othered" => 0, "failed" => 0 }, policy)

    get :index, :params => { :search => "comply_with=#{@policy.name}" }, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
    assert_equal 2, response['results'].count
  end

  test "should find reports inconclusive for policy" do
    reports_cleanup
    policy = FactoryBot.create(:policy)
    create_arf_report_for_search({ "passed" => 1, "othered" => 5, "failed" => 0 }, @policy)
    create_arf_report_for_search({ "passed" => 1, "othered" => 2, "failed" => 3 }, @policy)
    create_arf_report_for_search({ "passed" => 1, "othered" => 0, "failed" => 0 }, @policy)
    create_arf_report_for_search({ "passed" => 1, "othered" => 2, "failed" => 0 }, @policy)
    create_arf_report_for_search({ "passed" => 2, "othered" => 3, "failed" => 0 }, policy)

    get :index, :params => { :search => "inconclusive_with=#{@policy.name}" }, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
    assert_equal 2, response['results'].count
  end

  test "should find reports failing for policy" do
    reports_cleanup
    policy = FactoryBot.create(:policy)
    create_arf_report_for_search({ "passed" => 0, "othered" => 0, "failed" => 1 }, @policy)
    create_arf_report_for_search({ "passed" => 1, "othered" => 0, "failed" => 0 }, @policy)
    create_arf_report_for_search({ "passed" => 1, "othered" => 2, "failed" => 0 }, @policy)
    create_arf_report_for_search({ "passed" => 1, "othered" => 2, "failed" => 4 }, @policy)
    create_arf_report_for_search({ "passed" => 2, "othered" => 3, "failed" => 7 }, policy)

    get :index, :params => { :search => "not_comply_with=#{@policy.name}" }, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
    assert_equal 2, response['results'].count
  end

  test "should find last report for policy" do
    reports_cleanup
    policy = FactoryBot.create(:policy)
    create_arf_report_for_search({ "passed" => 1, "othered" => 0, "failed" => 0 }, @policy)
    create_arf_report_for_search({ "passed" => 1, "othered" => 0, "failed" => 4 }, @policy)
    create_arf_report_for_search({ "passed" => 1, "othered" => 0, "failed" => 0 }, policy)
    create_arf_report_for_search({ "passed" => 2, "othered" => 3, "failed" => 7 }, policy)

    get :index, :params => { :search => "last_for=policy" }, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
    assert_equal 2, response['results'].count
    assert_equal 7, response['results'].find { |hash| hash["policy"]["name"] == policy.name }["failed"]
    assert_equal 4, response['results'].find { |hash| hash["policy"]["name"] == @policy.name }["failed"]
  end

  test "should find last report for hosts" do
    reports_cleanup
    host_a = FactoryBot.create(:compliance_host)
    host_b = FactoryBot.create(:compliance_host)
    policy = FactoryBot.create(:policy)
    create_arf_report_for_search({ "passed" => 1, "othered" => 0, "failed" => 0 }, policy, host_a)
    create_arf_report_for_search({ "passed" => 1, "othered" => 0, "failed" => 4 }, policy, host_a)
    create_arf_report_for_search({ "passed" => 1, "othered" => 0, "failed" => 0 }, policy, host_b)
    create_arf_report_for_search({ "passed" => 2, "othered" => 3, "failed" => 7 }, policy, host_b)
    # Add config reports to test for STI type
    FactoryBot.create(:config_report, :host_id => host_a.id)
    FactoryBot.create(:config_report, :host_id => host_b.id)

    get :index, :params => { :search => "last_for=host" }, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
    assert_equal 2, response['results'].count
    assert_equal 4, response['results'].find { |hash| hash["host"]["name"] == host_a.name }["failed"]
    assert_equal 7, response['results'].find { |hash| hash["host"]["name"] == host_b.name }["failed"]
  end

  test "should find passed reports by compliance status" do
    reports_cleanup
    policy = FactoryBot.create(:policy)
    passing_1 = create_arf_report_for_search({ "passed" => 4, "othered" => 0, "failed" => 0 }, policy)
    passing_2 = create_arf_report_for_search({ "passed" => 1, "othered" => 0, "failed" => 0 }, policy)
    create_arf_report_for_search({ "passed" => 15, "othered" => 9, "failed" => 0 }, policy)
    create_arf_report_for_search({ "passed" => 2, "othered" => 3, "failed" => 7 }, policy)

    get :index, :params => { :search => "compliance_status=compliant" }, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
    assert_equal 2, response['results'].count
    response['results'].each do |result|
      assert(result['passed'] > 0)
      assert(result['othered'] = 0)
      assert(result['failed'] = 0)
    end
  end

  test "should find failed reports by compliance status" do
    reports_cleanup
    policy = FactoryBot.create(:policy)
    create_arf_report_for_search({ "passed" => 4, "othered" => 0, "failed" => 1 }, policy)
    create_arf_report_for_search({ "passed" => 1, "othered" => 0, "failed" => 0 }, policy)
    create_arf_report_for_search({ "passed" => 15, "othered" => 9, "failed" => 0 }, policy)
    create_arf_report_for_search({ "passed" => 2, "othered" => 3, "failed" => 7 }, policy)

    get :index, :params => { :search => "compliance_status=incompliant" }, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
    assert_equal 2, response['results'].count
    response['results'].each do |result|
      assert(result['failed'] > 0)
    end
  end

  test "should find othered reports by compliance status" do
    reports_cleanup
    policy = FactoryBot.create(:policy)
    create_arf_report_for_search({ "passed" => 4, "othered" => 0, "failed" => 0 }, policy)
    create_arf_report_for_search({ "passed" => 1, "othered" => 42, "failed" => 0 }, policy)
    create_arf_report_for_search({ "passed" => 0, "othered" => 9, "failed" => 0 }, policy)
    create_arf_report_for_search({ "passed" => 2, "othered" => 3, "failed" => 7 }, policy)

    get :index, :params => { :search => "compliance_status=inconclusive" }, :session => set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert_response :success
    assert_equal 2, response['results'].count
    response['results'].each do |result|
      assert(result['failed'] = 0)
      assert(result['othered'] > 0)
    end
  end

  private

  def reports_cleanup
    reports = ForemanOpenscap::ArfReport.unscoped.all
    report_ids = reports.pluck(:id)
    all_logs = Log.where(:report_id => report_ids)
    Source.where(:id => all_logs.pluck(:source_id)).map(&:destroy)
    Message.where(:id => all_logs.pluck(:message_id)).map(&:destroy)
    all_logs.map(&:destroy)
    reports.map(&:destroy)
  end

  def arf_from_json(path)
    file_content = File.read path
    JSON.parse file_content
  end

  def create_arf_report_for_search(status, policy, host = @host)
    report = FactoryBot.create(:arf_report,
                               :host_id => host.id,
                               :status => status,
                               :metrics => status,
                               :openscap_proxy => @proxy)
    FactoryBot.create(:policy_arf_report, :policy_id => policy.id, :arf_report_id => report.id)
    report
  end

  def create_arf_report
    FactoryBot.create(:arf_report,
                      :host_id => @host.id,
                      :openscap_proxy => @proxy)
  end
end
