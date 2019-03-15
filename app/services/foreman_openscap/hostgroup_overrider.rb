module ForemanOpenscap
  class HostgroupOverrider
    def initialize(policy)
      @policy = policy
      @name_sevice = ConfigNameService.new
    end

    def populate
      return unless @policy.deploy_by && Policy.deploy_by_variants.include?(@policy.deploy_by)
      config = @name_sevice.config_for @policy.deploy_by.to_sym
      return unless config.available?
      return unless config.managed_overrides?
      @policy.hostgroups.each do |hostgroup|
        populate_overrides hostgroup, config
      end
    end

    private

    def add_config_tool(hostgroup, klass, name, collection_method)
      item = klass.find_by(:name => name)
      hostgroup.public_send(collection_method) << item unless hostgroup.public_send(collection_method).include? item
      item
    end

    def remove_config_tool(hostgroup, klass, name, collection_method)
      item = klass.find_by(:name => name)
      hostgroup.public_send(collection_method).delete(item) if hostgroup.public_send(collection_method).include? item
      item
    end

    def populate_overrides(hostgroup, config)
      item = add_config_tool hostgroup, config.config_item_class_name.constantize, config.config_item_name, config.collection_method
      return unless item
      add_overrides item.public_send(config.override_method_name), hostgroup, config
      depopulate_overrides hostgroup, config.type
    end

    def depopulate_overrides(hostgroup, type)
      @name_sevice.all_available_with_overrides_except(type).map do |remove_config|
        item = remove_config_tool hostgroup, remove_config.config_item_class_name.constantize, remove_config.config_item_name, remove_config.collection_method
        next unless item
        remove_overrides item.public_send(remove_config.override_method_name), hostgroup, remove_config
      end
    end

    def add_overrides(collection, hostgroup, config)
      collection.where(:override => true).find_each do |override|
        return unless hostgroup.openscap_proxy && (url = hostgroup.openscap_proxy.url).present?

        openscap_proxy_uri = URI.parse(url)
        case override.key
        when config.server_param
          lookup_value = LookupValue.where(:match => "hostgroup=#{hostgroup.to_label}", :lookup_key_id => override.id).first_or_initialize
          lookup_value.update_attribute(:value, openscap_proxy_uri.host)
        when config.port_param
          lookup_value = LookupValue.where(:match => "hostgroup=#{hostgroup.to_label}", :lookup_key_id => override.id).first_or_initialize
          lookup_value.update_attribute(:value, openscap_proxy_uri.port)
        end
      end
    end

    def remove_overrides(collection, hostgroup, config)
      collection.where(:override => true).find_each do |override|
        if override.key == config.server_param || override.key == config.port_param
          LookupValue.find_by(:match => "hostgroup=#{hostgroup.to_label}", :lookup_key_id => override.id)&.destroy
        end
      end
    end
  end
end
