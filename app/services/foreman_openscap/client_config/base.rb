module ForemanOpenscap
  module ClientConfig
    class Base
      delegate :server_param, :port_param, :policies_param, :config_item_name,
               :config_item_class_name, :override_method_name, :msg_name,
               :lookup_key_plural_name, :to => :constants

      def type
        raise NotImplementedError
      end

      def inline_help
        {
          :text => '',
          :replace_text => '',
          :route_helper_method => nil
        }
      end

      def managed_overrides?
        true
      end

      def available?
        raise NotImplementedError
      end

      def constants
        raise NotImplementedError
      end

      def collection_method
        constants.config_item_class_name&.pluralize&.underscore
      end

      def all_collection_method
        "all_#{collection_method}".to_sym
      end

      def find_config_item(scope = config_item_class_name.constantize)
        return scope.find_by :name => config_item_name if scope.respond_to?(:find_by)
        # all_puppetclasses, all_ansible_roles methods return Array, not ActiveRecord::Relation
        scope.find { |item| item.name == config_item_name }
      end
    end
  end
end
