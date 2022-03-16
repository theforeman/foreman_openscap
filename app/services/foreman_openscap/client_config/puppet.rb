module ForemanOpenscap
  module ClientConfig
    class Puppet < Base
      delegate :puppetclass_name, :to => :constants

      alias config_item_name puppetclass_name

      def type
        :puppet
      end

      def available?
        Foreman::Plugin.installed?("foreman_puppet")
      end

      def inline_help
        {
          :text => "Requires #{puppetclass_name} Puppet class. This will assign the class to the hosts or selected hostgroups.<br>Every puppet run ensures the foreman_scap_client is configured according to the policy.",
          :replace_text => 'Puppet class',
          :route_helper_method => :hash_for_puppetclasses_path
        }
      end

      def collection_method
        :puppetclasses
      end

      def constants
        OpenStruct.new(
          :server_param => 'server',
          :port_param => 'port',
          :policies_param => 'policies',
          :puppetclass_name => 'foreman_scap_client',
          :config_item_class_name => 'ForemanPuppet::Puppetclass',
          :override_method_name => 'class_params',
          :msg_name => _('Puppet class'),
          :lookup_key_plural_name => _('Smart Class Parameters'),
          :policies_param_default_value => ds_policies_param_default_value
        )
      end
    end
  end
end
