module ForemanOpenscap
  class HostgroupOverrider
    include HostgroupOverriderCommon

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
  end
end
