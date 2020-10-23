module ForemanOpenscap
  module LookupKeyOverridesCommon
    extend ActiveSupport::Concern

    def override(config)
      return unless handle_config_not_available(config)
      override_required_params config
    end

    def override_required_params(config)
      item = config.find_config_item

      return unless handle_config_item_not_available(config, item)
      return unless config.managed_overrides?
      override_params item.public_send(config.override_method_name), config
    end

    def override_params(lookup_keys, config)
      policies_param = lookup_keys.find_by :key => config.policies_param
      port_param = lookup_keys.find_by :key => config.port_param
      server_param = lookup_keys.find_by :key => config.server_param

      missing_keys = missing_lookup_keys(config.policies_param => policies_param,
                                         config.port_param => port_param,
                                         config.server_param => server_param)

      return unless handle_missing_lookup_keys config, missing_keys.compact.join(', ')

      override_policies_param(policies_param, config)
      override_port_param(port_param, config)
      override_server_param(server_param, config)
    end

    def override_policies_param(parameter, config)
      override_param 'policies', config.policies_param, parameter, config, 'array', config.policies_param_default_value
    end

    def override_port_param(param, config)
      override_param 'port', config.port_param, param, config, 'integer'
    end

    def override_server_param(param, config)
      override_param 'server', config.server_param, param, config, 'string'
    end

    def override_param(handler, param_name, param, config, key_type, default_value = nil)
      param.override = true
      param.hidden_value = false
      param.key_type = key_type
      param.default_value = default_value

      send("handle_#{handler}_param_override", config, param)
    end

    def missing_lookup_keys(hash)
      return [] if hash.values.all?
      hash.reduce([]) do |memo, (key, value)|
        memo << key if value.blank?
        memo
      end
    end
  end
end
