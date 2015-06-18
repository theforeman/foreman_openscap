require 'test_plugin_helper'

class BulkUploadTest < ActiveSupport::TestCase
  setup do
    require 'foreman_openscap/bulk_upload'
  end

  test 'upload_from_files should create only one scap content' do
    scap_files = ['../foreman_openscap/test/files/scap_contents/ssg-fedora-ds.xml']
    assert_difference('Scaptimony::ScapContent.count', 1) do
      2.times do
        ForemanOpenscap::BulkUpload.new.upload_from_files(scap_files)
      end
    end
  end
end