require 'test_plugin_helper'
require 'foreman_openscap/document_migration'

class DocumentMigrationTest < ActiveSupport::TestCase
  setup do
    @records = [:scap_content, :tailoring_file].map do |factory|
      record = FactoryBot.create(factory)
      content = record.scap_file
      blob = record.scap_document.blob
      record.scap_document_attachment.delete
      blob.purge
      record.update_columns(:scap_file => content)
      record.reload
    end
    @output = StringIO.new
  end

  def run_migration(**options)
    ForemanOpenscap::DocumentMigration.new(:output => @output, **options).run
  end

  test 'preview leaves SQL, profiles, attachments and objects unchanged' do
    ForemanOpenscap::VerifiedDocument.expects(:upload).never
    result = run_migration
    assert_equal 2, result[:eligible]
    @records.each do |record|
      refute record.reload.scap_document.attached?
      assert record.scap_file.present?
    end
  end

  test 'copy verifies both document types, keeps SQL, and is repeatable without a proxy' do
    sources = @records.map(&:scap_file)
    digests = @records.map(&:digest)
    ProxyAPI::Openscap.any_instance.expects(:validate_scap_file).never
    ProxyAPI::Openscap.any_instance.expects(:fetch_policies_for_scap_content).never
    ProxyAPI::Openscap.any_instance.expects(:fetch_profiles_for_tailoring_file).never
    assert_equal 2, run_migration(:apply => true)[:migrated]
    @records.each_with_index do |record, index|
      assert_equal sources[index], record.reload.scap_file
      assert_equal sources[index], record[:scap_file]
      assert_equal digests[index], record.digest
    end
    ForemanOpenscap::VerifiedDocument.expects(:upload).never
    assert_equal 2, run_migration(:apply => true)[:already_stored]
  end

  test 'bad source digest is reported without attaching or removing SQL data' do
    @records.first.update_columns(:digest => 'invalid')
    result = run_migration(:apply => true)
    assert_equal 1, result[:failed]
    assert_equal 1, result[:migrated]
    refute @records.first.reload.scap_document.attached?
    assert @records.first[:scap_file].present?
  end

  test 'cleanup refuses documents that have not been copied' do
    assert_equal 2, run_migration(:cleanup => true, :apply => true)[:failed]
    @records.each { |record| assert record.reload[:scap_file].present? }
  end

  test 'cleanup preview retains SQL; apply clears only verified SQL copies' do
    run_migration(:apply => true)
    assert_equal 2, run_migration(:cleanup => true)[:eligible]
    @records.each { |record| assert record.reload[:scap_file].present? }
    assert_equal 2, run_migration(:cleanup => true, :apply => true)[:cleaned]
    @records.each do |record|
      assert_nil record.reload[:scap_file]
      assert record.scap_file.present?
    end
    assert_equal 0, run_migration(:cleanup => true, :apply => true)[:cleaned]
  end

  test 'missing stored object prevents cleanup and leaves source readable' do
    run_migration(:apply => true)
    blob = @records.first.reload.scap_document.blob
    blob.service.delete(blob.key)
    assert_equal 1, run_migration(:cleanup => true, :apply => true)[:failed]
    assert @records.first.reload[:scap_file].present?
  end

  test 'stored bytes must match the current model digest before SQL cleanup' do
    run_migration(:apply => true)
    @records.first.update_columns(:digest => 'invalid')
    assert_equal 1, run_migration(:cleanup => true, :apply => true)[:failed]
    assert @records.first.reload[:scap_file].present?
  end

  test 'corrupt stored bytes prevent cleanup even when the SQL digest is valid' do
    run_migration(:apply => true)
    blob = @records.first.reload.scap_document.blob
    blob.service.upload(blob.key, StringIO.new('corrupt'))
    assert_equal 1, run_migration(:cleanup => true, :apply => true)[:failed]
    assert @records.first.reload[:scap_file].present?
  end

  test 'copy failure removes only the failed new blob and retains SQL' do
    service = ActiveStorage::Blob.service
    service.expects(:upload).twice.raises(IOError)
    before = ActiveStorage::Blob.count
    result = run_migration(:apply => true)
    assert_equal 2, result[:failed]
    assert_equal before, ActiveStorage::Blob.count
    refute @records.first.reload.scap_document.attached?
    assert @records.first[:scap_file].present?
  end
end
