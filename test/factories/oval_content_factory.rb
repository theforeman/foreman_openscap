FactoryBot.define do
  factory :oval_content, :class => ::ForemanOpenscap::OvalContent do |f|
    f.sequence(:name) { |n| "oval_content_#{n}" }
    f.original_filename { 'test-oval.xml' }
    f.scap_file { '<xml>foo</xml>' }
  end
end
