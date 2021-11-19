module ForemanOpenscap
  module Oval
    class Configure
      include ::ForemanOpenscap::HostgroupOverriderCommon

      def initialize
        @config = ForemanOpenscap::ClientConfig::Ansible.new(::ForemanOpenscap::OvalPolicy)
      end

      def assign(oval_policy, ids, model_class)
        check_collection = ::ForemanOpenscap::Oval::Setup.new.run
        return check_collection unless check_collection.all_passed?

        ansible_role = @config.find_config_item

        if model_class == ::Hostgroup
          roles_method = :inherited_and_own_ansible_roles
          ids_setter = :hostgroup_ids=
          check_id = :hostgroups_without_proxy
        elsif model_class == ::Host::Managed
          roles_method = :all_ansible_roles
          ids_setter = :host_ids=
          check_id = :hosts_without_proxy
        else
          raise "Unexpected model_class, expected ::Hostgroup or ::Host::Managed, got: #{model_class}"
        end

        items_with_proxy, items_without_proxy = openscap_proxy_associated(ids, model_class)


        if items_without_proxy.any?
          return without_proxy_to_check items_without_proxy, check_id
        end

        oval_policy.send(ids_setter, items_with_proxy.pluck(:id))

        unless oval_policy.save
          return check_collection.add_check model_to_check(oval_policy, :oval_policy_errors)
        end

        check_collection.merge modify_items(items_with_proxy, oval_policy, ansible_role, roles_method)
      end

      private

      def openscap_proxy_associated(ids, model_class)
        model_class.where(:id => ids).partition(&:openscap_proxy)
      end

      def modify_items(items, oval_policy, ansible_role, roles_method)
        items.reduce(CheckCollection.new) do |memo, item|
          role_ids = item.ansible_role_ids + [ansible_role.id]
          item.ansible_role_ids = role_ids unless item.send(roles_method).include? ansible_role
          item.save if item.changed?
          memo.add_check model_to_check(item, item.is_a?(::Hostgroup) ? 'hostgroup' : 'host')
          add_overrides ansible_role.ansible_variables, item, @config
          memo
        end
      end

      def without_proxy_to_check(items, check_id)
        items.reduce(CheckCollection.new) do |memo, item|
          memo.add_check(
            SetupCheck.new(
              :title => (_("Was %s configured successfully?") % item.class.name),
              :fail_msg => (_("Assign openscap_proxy to %s before proceeding.") % item.name),
              :id => check_id
            ).fail!
          )
        end
      end

      def model_to_check(model, check_id)
        check = SetupCheck.new(
          :title => (_("Was %{model_name} %{name} configured successfully?") % { :model_name => model.class.name, :name => model.name }),
          :errors => model.errors.to_h,
          :id => check_id
        )
        model.errors.any? ? check.fail! : check.pass!
      end
    end
  end
end
