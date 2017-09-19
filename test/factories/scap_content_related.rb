include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :scap_content, :class => ::ForemanOpenscap::ScapContent do |f|
    f.sequence(:title) { |n| "scap_content_title_#{n}" }
    f.original_filename 'fedora ds'
    f.scap_file { File.new("#{ForemanOpenscap::Engine.root}/test/files/scap_contents/ssg-fedora-ds.xml", 'rb').read }
  end

  factory :scap_content_profile, :class => ::ForemanOpenscap::ScapContentProfile do |f|
    f.scap_content
    f.profile_id 'xccdf_org.test.common_test_profile'
    f.title 'test Profile for testing'
  end

  factory :tailoring_file, :class => ForemanOpenscap::TailoringFile do |f|
    f.sequence(:name) { |n| "tailoring_file_#{n}" }
    f.original_filename 'original tailoring filename'
    f.scap_file { File.new("#{ForemanOpenscap::Engine.root}/test/files/tailoring_files/ssg-firefox-ds-tailoring.xml", 'rb').read }
    f.scap_content_profiles []
  end
end
