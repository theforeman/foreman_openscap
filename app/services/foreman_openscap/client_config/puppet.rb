module ForemanOpenscap
  module ClientConfig
    class Puppet < Base
      delegate :puppetclass_name, :to => :constants

      alias config_item_name puppetclass_name

      def type
        :puppet
      end

      def available?
        defined?(Puppetclass)
      end

      def constants
        OpenStruct.new(
          :server_param => 'server',
          :port_param => 'port',
          :policies_param => 'policies',
          :puppetclass_name => 'foreman_scap_client',
          :config_item_class_name => 'Puppetclass',
          :override_method_name => 'class_params',
          :msg_name => 'Puppet class'
        )
      end
    end
  end
end
