object @oval_policy

extends "api/v2/compliance/common/org"
extends "api/v2/compliance/common/loc"
extends "api/v2/compliance/policies_common/attrs"

attributes :created_at, :updated_at, :oval_content_id

child :hosts => :hosts do |host|
  attributes :id, :name
end

child :hostgroups => :hostgroups do |hg|
  attributes :id, :name
end
