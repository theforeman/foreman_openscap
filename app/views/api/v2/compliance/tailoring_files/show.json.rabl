object @tailoring_file

extends "api/v2/compliance/tailoring_files/main"

child :scap_content_profiles => :tailoring_file_profiles do |profile|
  attributes :id, :profile_id, :title
end
