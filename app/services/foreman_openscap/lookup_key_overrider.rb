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
        err = _("Required #{config.msg_name} %{class} was not found, please ensure it is imported first.") % { :class => config.config_item_name }
        @policy.errors[:base] << err
        return
      end

      item.public_send(config.override_method_name).map do |lookup_key|
        override_params(lookup_key, config)
      end
    end

    def override_params(lookup_key, config)
      return override_policies_param(lookup_key, config) if lookup_key.key == config.policies_param
      return override_port_param(lookup_key, config) if lookup_key.key == config.port_param
      return override_server_param(lookup_key, config) if lookup_key.key == config.server_param
    end

    def override_policies_param(parameter, config)
      override_param(config.policies_param, parameter, config) do |param|
        param.key_type      = 'array'
        param.default_value = '<%= @host.policies_enc %>'
      end
    end

    def override_port_param(param, config)
      override_param config.port_param, param, config
    end

    def override_server_param(param, config)
      override_param config.server_param, param, config
    end

    def override_param(param_name, param, config)
      param.override = true
      param.hidden_value = false

      yield param if block_given?

      if param.changed? && !param.save
        @policy.errors[:base] <<
          _('Failed to save when overriding parameters for %{config_tool}, cause: %{errors}') %
          { :config_tool => config.type, :errors => param.errors.full_messages.join(', ') }
      end
    end
  end
end
