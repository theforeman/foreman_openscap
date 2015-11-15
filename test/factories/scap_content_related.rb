include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :scap_content, :class => ::ForemanOpenscap::ScapContent do |f|
    f.title 'fedora'
    f.original_filename 'fedora ds'
    f.scap_file { File.new("#{ForemanOpenscap::Engine.root}/test/files/scap_contents/ssg-fedora-ds.xml", 'rb').read }
  end

  factory :scap_content_profile, :class => ::ForemanOpenscap::ScapContentProfile do |f|
    f.scap_content
    f.profile_id 'xccdf_org.test.common_test_profile'
    f.title 'test Profile for testing'
  end
end
