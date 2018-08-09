module ForemanOpenscap
  module ClientConfig
    class Ansible < Base
      delegate :ansible_role_name, :to => :constants

      alias config_item_name ansible_role_name

      def type
        :ansible
      end

      def available?
        defined?(ForemanAnsible)
      end

      def help_text
        "Make sure you have Ansible plugin installed and #{ansible_role_name} Ansible role imported."
      end

      def constants
        OpenStruct.new(
          :server_param => 'foreman_scap_client_server',
          :port_param => 'foreman_scap_client_port',
          :policies_param => 'foreman_scap_client_policies',
          :ansible_role_name => 'theforeman.foreman_scap_client',
          :config_item_class_name => 'AnsibleRole',
          :override_method_name => 'ansible_variables',
          :msg_name => 'Ansible role'
        )
      end
    end
  end
end
