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
  end

  test "should get index" do
    create_arf_report
    get :index, {}, set_session_user
    response = ActiveSupport::JSON.decode(@response.body)
    assert_not response['results'].empty?
    assert_response :success
  end

  test "should get show" do
    report = create_arf_report
    get :show, { :id => report.to_param }, set_session_user
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
    get :download, { :id => report.to_param }, set_session_user
    t = Tempfile.new('tmp_report')
    t.write @response.body
    t.close
    refute t.size.zero?
  end

  test "should create report" do
    reports_cleanup
    date = Time.new(1984, 9, 15)
    ForemanOpenscap::Helper.stubs(:get_asset).returns(@asset)
    post :create,
         @from_json.merge(:cname => @cname,
                          :policy_id => @policy.id,
                          :date => date.to_i),
         set_session_user
    report = ForemanOpenscap::ArfReport.unscoped.last
    assert_equal date, report.reported_at
    report_logs = report.logs
    msg_count = report_logs.flat_map(&:message).count
    src_count = report_logs.flat_map(&:source).count
    assert(msg_count > 0)
    assert_equal msg_count, src_count
  end

  test "should not create report for host without proxy" do
    asset = FactoryBot.create(:asset)
    date = Time.new(1944, 6, 6)
    ForemanOpenscap::Helper.stubs(:get_asset).returns(asset)
    post :create,
         @from_json.merge(:cname => @cname,
                          :policy_id => @policy.id,
                          :date => date.to_i),
         set_session_user
    assert_response :unprocessable_entity
    res = JSON.parse(@response.body)
    assert_equal "Failed to upload Arf Report, no OpenSCAP proxy set for host #{asset.host.name}", res["result"]
  end

  test "should not duplicate messages" do
    dates = [Time.new(1984, 9, 15), Time.new(1932, 3, 27)]
    params = @from_json.with_indifferent_access.merge(:cname => @cname,
                                                      :policy_id => @policy.id,
                                                      :date => dates[0].to_i)
    assert ForemanOpenscap::ArfReport.create_arf(@asset, params)

    ForemanOpenscap::Helper.stubs(:get_asset).returns(@asset)
    post :create,
         @from_json.merge(:cname => @cname,
                          :policy_id => @policy.id,
                          :date => dates[1].to_i),
         set_session_user
    assert_equal Message.where(:digest => ForemanOpenscap::ArfReport.unscoped.last.logs.first.message.digest).count, 1
  end

  test "should recognize changes in messages" do
    params = @from_json.with_indifferent_access.merge(:cname => @cname,
                                                      :policy_id => @policy.id,
                                                      :date => Time.new(2017, 5, 6).to_i)
    assert ForemanOpenscap::ArfReport.create_arf(@asset, params)

    ForemanOpenscap::Helper.stubs(:get_asset).returns(@asset)
    changed_from_json = arf_from_json "#{ForemanOpenscap::Engine.root}/test/files/arf_report/arf_report_msg_desc_changed.json"
    post :create,
         changed_from_json.merge(:cname => @cname,
                                 :policy_id => @policy.id,
                                 :date => Time.new(2017, 6, 6).to_i),
         set_session_user

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
    assert ForemanOpenscap::ArfReport.create_arf(@asset, params)

    ForemanOpenscap::Helper.stubs(:get_asset).returns(@asset)
    changed_from_json = arf_from_json "#{ForemanOpenscap::Engine.root}/test/files/arf_report/arf_report_msg_value_changed.json"
    post :create,
         changed_from_json.merge(:cname => @cname,
                                 :policy_id => @policy.id,
                                 :date => Time.new(2017, 8, 6).to_i),
         set_session_user

    assert_response :success

    reports = ForemanOpenscap::ArfReport.unscoped.all
    assert_equal reports.count, 2

    new_msgs = Message.where(:value => "Disable Firefox Configuration File ROT-13 Encoding Changed For Test")
    old_msgs = Message.where(:value => "Disable Firefox Configuration File ROT-13 Encoding")
    assert_equal new_msgs.count, 1
    assert_equal old_msgs.count, 0
    assert_equal new_msgs.first.digest, Digest::SHA1.hexdigest("Disable Firefox Configuration File ROT-13 Encoding Changed For Test")
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

  def create_arf_report
    FactoryBot.create(:arf_report,
                      :host_id => @host.id,
                      :openscap_proxy => FactoryBot.create(:smart_proxy, :url => "http://smart-proxy.org:8000"))
  end
end
