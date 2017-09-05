object @policy

child :hostgroups => :hostgroups do |hostgroup|
  attributes :id, :name, :title
end

extends "api/v2/compliance/policies/main"
