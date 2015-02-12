include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :scap_content, :class => Scaptimony::ScapContent do |f|
    f.title 'fedora'
    f.original_filename 'fedora ds'
    f.scap_file { File.new('../foreman_openscap/test/files/scap_contents/ssg-fedora-ds.xml', 'rb').read }
  end

  factory :scap_content_profile, :class => Scaptimony::ScapContentProfile do |f|
    f.scap_content
    f.profile_id 'xccdf_org.test.common_test_profile'
    f.title 'test Profile for testing'
  end
end
