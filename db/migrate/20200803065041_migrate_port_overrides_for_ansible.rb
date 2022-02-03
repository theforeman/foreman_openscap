class MigratePortOverridesForAnsible < ActiveRecord::Migration[6.0]
  def up
    transform_lookup_values :to_i
  end

  def down
    transform_lookup_values :to_s
  end

  private

  def transform_lookup_values(method)
    return unless Foreman::Plugin.installed?("foreman_ansible")
    role = AnsibleRole.find_by :name => 'theforeman.foreman_scap_client'
    return unless role
    port_key = role.ansible_variables.find_by :key => 'foreman_scap_client_port'
    return unless port_key
    if method == :to_i
      port_key.key_type =  "integer"
      port_key.default_value = 8080
    else
      port_key.key_type == "string"
      port_key.default_value = ""
    end

    port_key.save
    port_key.lookup_values.in_batches do |batch|
      batch.each do |lookup_value|
        lookup_value.value = lookup_value.value.send(method)
        lookup_value.save
      end
    end
  end
end
