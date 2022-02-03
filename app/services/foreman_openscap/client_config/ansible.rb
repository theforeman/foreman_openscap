module ForemanOpenscap
  module ClientConfig
    class Ansible < Base
      delegate :ansible_role_name, :to => :constants
      attr_reader :constants

      alias config_item_name ansible_role_name

      def initialize(policy_class)
        raise "Unknown policy class, expected one of: #{policy_types.map(&to_s).join(', ')}" unless policy_types.include?(policy_class)
        initialize_constants(policy_class)
      end

      def type
        :ansible
      end

      def available?
        Foreman::Plugin.installed?("foreman_ansible")
      end

      def inline_help
        {
          :text => "Requires Ansible plugin, #{ansible_role_name} Ansible role and variables. This will assign the role to the hosts or selected hostgroups.<br>To deploy foreman_scap_client, ansible roles run needs to be triggered manually. Manual run is also required after any change to this policy.",
          :replace_text => 'Ansible role',
          :route_helper_method => :hash_for_ansible_roles_path
        }
      end

      def ansible_role_missing_msg
        _("theforeman.foreman_scap_client Ansible Role not found, please import it before running this action again.")
      end

      private

      def policy_types
        [ForemanOpenscap::Policy, ForemanOpenscap::OvalPolicy]
      end

      def initialize_constants(policy_class)
        base_constants = {
          :server_param => 'foreman_scap_client_server',
          :port_param => 'foreman_scap_client_port',
          :ansible_role_name => 'theforeman.foreman_scap_client',
          :config_item_class_name => 'AnsibleRole',
          :override_method_name => 'ansible_variables',
        }

        if policy_class == ::ForemanOpenscap::Policy
          @constants = OpenStruct.new(
            base_constants.merge(
              :policies_param => 'foreman_scap_client_policies',
              :policies_param_default_value => ds_policies_param_default_value,
              :msg_name => _('Ansible role'),
              :lookup_key_plural_name => _('Ansible variables')
            )
          )
        end

        if policy_class == ::ForemanOpenscap::OvalPolicy
          @constants = OpenStruct.new(
            base_constants.merge(
              :policies_param => 'foreman_scap_client_oval_policies',
              :policies_param_default_value => '<%= @host.oval_policies_enc %>'
            )
          )
        end
      end
    end
  end
end
