object @oval_content

attributes :id, :name

node(:errors) do |content|
  content.errors.to_hash
end

node(:full_messages) do |content|
  content.errors.full_messages
end
