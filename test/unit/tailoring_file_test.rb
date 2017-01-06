require 'test_plugin_helper'

class TailoringFileTest < ActiveSupport::TestCase
  setup do
    @scap_file = File.new("#{ForemanOpenscap::Engine.root}/test/files/tailoring_files/ssg-firefox-ds-tailoring.xml", 'rb').read
  end

  test 'should create tailoring file' do
    tailoring_file = ForemanOpenscap::TailoringFile.create(:name => 'test_file', :scap_file => @scap_file, :original_filename => 'original name')
    assert tailoring_file.valid?
  end

  test 'should not create tailoring_file without scap file' do
    tailoring_file = ForemanOpenscap::TailoringFile.create(:name => 'test_file', :original_filename => 'original name')
    refute tailoring_file.valid?
  end

  test 'should redigist when scap file changed' do
    scap_file = File.new("#{ForemanOpenscap::Engine.root}/test/files/tailoring_files/ssg-firefox-ds-tailoring-2.xml", 'rb').read
    tailoring_file = ForemanOpenscap::TailoringFile.create(:name => 'test_file', :scap_file => @scap_file, :original_filename => 'original name')
    original_digest = tailoring_file.digest
    tailoring_file.scap_file = scap_file
    assert tailoring_file.save
    refute_equal original_digest, tailoring_file.digest
  end
end
