class UpdatePuppetPortParamType < ActiveRecord::Migration[6.0]
  def up
    update_port_type :to_i
  end

  def down
    update_port_type :to_s
  end

  private

  def update_port_type(method)
    puppet_class = Puppetclass.find_by :name => 'foreman_scap_client'
    return unless puppet_class
    port_key = puppet_class.class_params.find_by :key => 'port'
    return unless port_key
    def_value = port_key.default_value

    if method == :to_i
      port_key.key_type =  "integer"
      port_key.default_value = def_value.to_i
    else
      port_key.key_type == "string"
      port_key.default_value = port_key.default_value.to_s
    end
    port_key.save!
  end
end
