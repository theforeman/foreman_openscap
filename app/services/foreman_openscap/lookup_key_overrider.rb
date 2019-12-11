module ForemanOpenscap
  class LookupKeyOverrider
    def initialize(policy)
      @policy = policy
      @name_service = ConfigNameService.new
    end

    def override
      return unless @policy.deploy_by && Policy.deploy_by_variants.include?(@policy.deploy_by)
      config = @name_service.config_for @policy.deploy_by.to_sym
      unless config.available?
        @policy.errors[:deploy_by] <<
          _("%{type} was selected to deploy policy to clients, but %{type} is not available. Are you missing a plugin?") %
          { :type => config.type.to_s.camelize }
        return
      end
      return unless config.managed_overrides?
      override_required_params config
    end

    private

    def override_required_params(config)
      item = config.find_config_item

      unless item
        err = _("Required %{msg_name} %{class} was not found, please ensure it is imported first.") %
          { :class => config.config_item_name, :msg_name => config.msg_name }
        @policy.errors[:base] << err
        return
      end

      override_params item.public_send(config.override_method_name), config
    end

    def override_params(lookup_keys, config)
      policies_param = lookup_keys.find_by :key => config.policies_param
      port_param = lookup_keys.find_by :key => config.port_param
      server_param = lookup_keys.find_by :key => config.server_param

      return unless all_lookup_keys_present?(config, config.policies_param => policies_param,
                                                     config.port_param => port_param,
                                                     config.server_param => server_param)

      override_policies_param(policies_param, config)
      override_port_param(port_param, config)
      override_server_param(server_param, config)
    end

    def all_lookup_keys_present?(config, hash)
      unless hash.values.all?
        names = hash.reduce([]) do |memo, (key, value)|
          memo << key if value.blank?
          memo
        end

        err = _("The following %{key_name} were missing for %{item_name}: %{key_names}. Make sure they are imported before proceeding.") %
          { :key_name => config.lookup_key_plural_name, :key_names => names.compact.join(', '), :item_name => config.config_item_name }

        @policy.errors[:base] << err
        return false
      end
      true
    end

    def override_policies_param(parameter, config)
      override_param(config.policies_param, parameter, config) do |param|
        param.key_type      = 'array'
        param.default_value = '<%= @host.policies_enc %>'
      end
    end

    def override_port_param(param, config)
      override_param config.port_param, param, config, 'integer'
    end

    def override_server_param(param, config)
      override_param config.server_param, param, config
    end

    def override_param(param_name, param, config, key_type = nil)
      param.override = true
      param.hidden_value = false
      param.key_type = key_type if key_type

      yield param if block_given?

      if param.changed? && !param.save
        @policy.errors[:base] <<
          _('Failed to save when overriding parameters for %{config_tool}, cause: %{errors}') %
          { :config_tool => config.type, :errors => param.errors.full_messages.join(', ') }
      end
    end
  end
end
