require 'test_plugin_helper'

class StoredScapFileTest < ActiveSupport::TestCase
  [:scap_content, :tailoring_file].each do |factory|
    test "#{factory} stores new XML outside SQL and preserves the byte interface" do
      record = FactoryBot.build(factory)
      content = record.scap_file.dup
      record.save!

      assert_nil record.reload[:scap_file]
      assert record.scap_document.attached?
      assert_equal content.b, record.scap_file.b
      assert_equal Digest::SHA256.hexdigest(content), record.digest
      assert_equal content.b, record.scap_document.download.b
    end

    test "#{factory} does not upload unchanged content or metadata" do
      record = FactoryBot.create(factory)
      blob_id = record.scap_document.blob.id
      record.scap_file = record.scap_file
      ForemanOpenscap::VerifiedDocument.expects(:upload).never
      record.save!
      record.update!(:original_filename => 'renamed.xml')
      assert_equal blob_id, record.reload.scap_document.blob.id
    end

    test "#{factory} rejects an empty replacement without losing the original" do
      record = FactoryBot.create(factory)
      content = record.scap_file
      record.scap_file = nil
      refute record.save
      assert_equal content, record.reload.scap_file
    end

    test "#{factory} leaves the previous document readable after an upload failure" do
      record = FactoryBot.create(factory)
      content = record.scap_file
      blob_id = record.scap_document.blob.id
      record.scap_file = content.sub('xml', 'xml ')
      ForemanOpenscap::VerifiedDocument.expects(:upload).raises(IOError)
      assert_raises(IOError) { record.save! }
      assert_equal blob_id, record.reload.scap_document.blob.id
      assert_equal content, record.scap_file
    end

    test "#{factory} deletes only its own new object after a transaction rollback" do
      record = FactoryBot.create(factory)
      original = record.scap_document.blob
      replacement = nil
      record.class.transaction(:requires_new => true) do
        record.update!(:scap_file => record.scap_file.sub('xml', 'xml '))
        replacement = record.scap_document.blob
        assert replacement.service.exist?(replacement.key)
        raise ActiveRecord::Rollback
      end
      refute replacement.service.exist?(replacement.key)
      assert original.service.exist?(original.key)
      assert_equal original.id, record.reload.scap_document.blob.id
    end
  end
end
