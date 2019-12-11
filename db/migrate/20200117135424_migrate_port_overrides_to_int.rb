class MigratePortOverridesToInt < ActiveRecord::Migration[5.2]
  def up
    transform_lookup_values :to_i
  end

  def down
    transform_lookup_values :to_s
  end

  private

  def transform_lookup_values(method)
    puppet_class = Puppetclass.find_by :name => 'foreman_scap_client'
    return unless puppet_class
    port_key = puppet_class.class_params.find_by :key => 'port'
    return unless port_key
    port_key.lookup_values.in_batches do |batch|
      batch.each do |lookup_value|
        lookup_value.value = lookup_value.value.send(method)
        lookup_value.save
      end
    end
  end
end
