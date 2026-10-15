require 'test_plugin_helper'

class VerifiedDocumentTest < ActiveSupport::TestCase
  test 'upload checks the stored content before returning a blob' do
    content = '<xml>verified</xml>'
    blob = ForemanOpenscap::VerifiedDocument.upload(content, 'test.xml')
    assert_equal content, blob.download
    assert_equal 'application/xml', blob.content_type
    assert_equal content.bytesize, blob.byte_size
  ensure
    blob.purge if blob
  end

  test 'failed read-back verification removes the new blob and object' do
    service = ActiveStorage::Blob.service
    uploaded_key = nil
    service.stubs(:download).with do |key, &block|
      uploaded_key = key
      true
    end.raises(ActiveStorage::IntegrityError)
    before = ActiveStorage::Blob.count
    assert_raises(ActiveStorage::IntegrityError) do
      ForemanOpenscap::VerifiedDocument.upload('<xml/>', 'test.xml')
    end
    assert_equal before, ActiveStorage::Blob.count
    assert uploaded_key
    refute service.exist?(uploaded_key)
  end
end
