class RemoveScaptimonyPermissions < ActiveRecord::Migration
  def up
    permissions = Permission.where(:resource_type => ["Scaptimony::Policy", "Scaptimony::ScapContent"])
    new_type = "ForemanOpenscap"
    permissions.each do |p|
      say "Converting permission '#{p.id}' with name '#{p.name}' of type '#{p.resource_type}' to new type '#{new_type}'"
      p.resource_type = p.resource_type.sub(/^Scaptimony/, new_type)
      p.save!
    end
  end

  def down
    permissions = Permission.where(:resource_type => ["ForemanOpenscap::Policy", "ForemanOpenscap::ScapContent"])
    permissions.each do |p|
      old_type = "Scaptimony"
      say "Converting permission '#{p.id}' with name '#{p.name}' of type '#{p.resource_type}' to new type '#{old_type}'"
      p.resource_type = p.resource_type.sub(/^ForemanOpenscap/, old_type)
      p.save!
    end
  end
end
