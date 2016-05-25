object @scap_content

extends "api/v2/compliance/scap_contents/main"

child :scap_content_profiles => :scap_content_profiles do |profile|
  attributes :id, :profile_id, :title
end
