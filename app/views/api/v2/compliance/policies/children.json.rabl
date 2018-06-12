object @policy

child :hosts => :hosts do |host|
  attributes :id, :name
end

child :hostgroups => :hostgroups do |hostgroup|
  attributes :id, :name, :title
end
