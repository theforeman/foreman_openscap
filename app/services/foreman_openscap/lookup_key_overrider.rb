module ForemanOpenscap
  class LookupKeyOverrider
    include LookupKeyOverridesCommon

    def initialize(policy)
      @policy = policy
      @name_service = ConfigNameService.new
    end

    def override
      return unless @policy.deploy_by && Policy.deploy_by_variants.include?(@policy.deploy_by)
      config = @name_service.config_for @policy.deploy_by.to_sym

      override config
    end

    def handle_config_not_available(config)
      return true if config.available?
      @policy.errors[:deploy_by] <<
        _("%{type} was selected to deploy policy to clients, but %{type} is not available. Are you missing a plugin?") %
          { :type => config.type.to_s.camelize }
      false
    end

    def handle_config_item_not_available(config, item)
      return true if item
      err = _("Required %{msg_name} %{class} was not found, please ensure it is imported first.") %
          { :class => config.config_item_name, :msg_name => config.msg_name }
      @policy.errors[:base] << err
      false
    end

    def handle_missing_lookup_keys(config, key_names)
      return true if key_names.empty?
      err = _("The following %{key_name} were missing for %{item_name}: %{key_names}. Make sure they are imported before proceeding.") %
        { :key_name => config.lookup_key_plural_name, :key_names => key_names, :item_name => config.config_item_name }

      @policy.errors[:base] << err
      false
    end

    def handle_server_param_override_error(config, param)
      handle_param_override_error config, param
    end

    def handle_port_param_override_error(config, param)
      handle_param_override_error config, param
    end

    def handle_policies_param_override_error(config, param)
      handle_param_override_error config, param
    end

    def handle_param_override_error(config, param)
      if param.changed? && !param.save
        @policy.errors[:base] <<
          _('Failed to save when overriding parameters for %{config_tool}, cause: %{errors}') %
          { :config_tool => config.type, :errors => param.errors.full_messages.join(', ') }
        return false
      end
      true
    end
  end
end
