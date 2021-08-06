module ForemanOpenscap
  module Oval
    class Setup
      include ::ForemanOpenscap::LookupKeyOverridesCommon

      def initialize
        @config = ForemanOpenscap::ClientConfig::Ansible.new(::ForemanOpenscap::OvalPolicy)
        @check_collection = CheckCollection.new initial_check_attrs
      end

      def run(dryrun = false)
        @dryrun = dryrun
        override @config
        @check_collection
      end

      def handle_config_not_available(config)
        return @check_collection.pass_check :foreman_ansible_present if config.available?
        fail_check :foreman_ansible_present
      end

      def handle_config_item_not_available(config, item)
        return @check_collection.pass_check :foreman_scap_client_role_present if item
        fail_check :foreman_scap_client_role_present
      end

      def handle_missing_lookup_keys(config, key_names)
        return @check_collection.pass_check :foreman_scap_client_vars_present if key_names.empty?
        fail_check :foreman_scap_client_vars_present, :missing_vars => key_names
      end

      def handle_server_param_override(config, param)
        handle_param_override :foreman_scap_client_server_overriden, config, param
      end

      def handle_port_param_override(config, param)
        handle_param_override :foreman_scap_client_port_overriden, config, param
      end

      def handle_policies_param_override(config, param)
        handle_param_override :foreman_scap_client_policies_overriden, config, param
      end

      def handle_param_override(check_id, config, param)
        changed = param.changed?
        return fail_check check_id if @dryrun && changed
        return fail_check check_id if !@dryrun && changed && !param.save
        @check_collection.pass_check check_id
      end

      def fail_check(check_id, error_data = nil)
        @check_collection.fail_check(check_id, error_data)
        false
      end

      private

      def initial_check_attrs
        override_msg = _("Ansible Variable was not set up correctly.")

        [
          {
            :id => :foreman_ansible_present,
            :title => _("Is foreman_ansible present?"),
            :fail_msg => _("foreman_ansible plugin not found, please install it before running this action again.")
          },
          {
            :id => :foreman_scap_client_role_present,
            :title => _("Is theforeman.foreman_scap_client present?"),
            :fail_msg => @config.ansible_role_missing_msg
          },
          {
            :id => :foreman_scap_client_vars_present,
            :title => _("Are required variables for theforeman.foreman_scap_client present?"),
            :fail_msg => ->(hash) { _("The following Ansible Variables were not found: %{missing_vars}, please import them before running this action again.") % hash }
          },
          {
            :id => :foreman_scap_client_server_overriden,
            :title => _("Is %s param set to be overriden?") % @config.server_param,
            :fail_msg => override_msg
          },
          {
            :id => :foreman_scap_client_port_overriden,
            :title => _("Is %s param set to be overriden?") % @config.port_param,
            :fail_msg => override_msg
          },
          {
            :id => :foreman_scap_client_policies_overriden,
            :title => _("Is %s param set to be overriden?") % @config.policies_param,
            :fail_msg => override_msg
          }
        ]
      end
    end
  end
end
