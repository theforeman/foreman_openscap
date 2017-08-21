object @policy

extends "api/v2/compliance/policies/main"

child :hostgroups => :hostgroups do |hg|
  attributes :id, :title
end
