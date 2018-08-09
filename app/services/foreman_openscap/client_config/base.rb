module ForemanOpenscap
  module ClientConfig
    class Base
      delegate :server_param, :port_param, :policies_param, :config_item_name,
               :config_item_class_name, :override_method_name, :msg_name, :to => :constants

      def type
        raise NotImplementedError
      end

      def help_text
        ''
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

      def find_config_item(scope = config_item_class_name.constantize)
        scope.find_by :name => config_item_name
      end
    end
  end
end
