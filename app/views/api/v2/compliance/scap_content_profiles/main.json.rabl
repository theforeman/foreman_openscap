extends "api/v2/compliance/scap_content_profiles/base"

child :scap_content => :scap_content do |scap_content|
  attributes :id, :title
end

child :tailoring_file => :tailoring_file do |tailoring_file|
  attributes :id, :name
end
