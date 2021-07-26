class UpdatePuppetPortParamType < ActiveRecord::Migration[6.0]
  def up
    update_port_type :to_i
  end

  def down
    update_port_type :to_s
  end

  private

  def update_port_type(method)
    return unless defined?(ForemanPuppet)
    puppet_class = ::ForemanPuppet::Puppetclass.find_by :name => 'foreman_scap_client'
    return unless puppet_class
    port_key = puppet_class.class_params.find_by :key => 'port'
    return unless port_key

    if method == :to_i
      port_key.update_columns(:key_type => "integer", :default_value => port_key.default_value.to_i)
    else
      port_key.update_columns(:key_type => "string", :default_value => port_key.default_value.to_s)
    end
  end
end
