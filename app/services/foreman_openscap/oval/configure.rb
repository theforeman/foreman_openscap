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
        elsif model_class == ::Host::Managed
          roles_method = :all_ansible_roles
          ids_setter = :host_ids=
        else
          raise "Unexpected model_class, expected ::Hostgroup or ::Host::Managed, got: #{model_class}"
        end

        items_with_proxy, items_without_proxy = openscap_proxy_associated(ids, model_class)

        oval_policy.send(ids_setter, items_with_proxy.pluck(:id))

        check_collection = without_proxy_to_check items_without_proxy

        unless oval_policy.save
          return check_collection.add_check model_to_check(oval_policy)
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
          memo.add_check model_to_check(item)
          add_overrides ansible_role.ansible_variables, item, @config
          memo
        end
      end

      def without_proxy_to_check(items)
        items.reduce(CheckCollection.new) do |memo, item|
          memo.add_check(
            SetupCheck.new(
              :title => (_("Was %s configured successfully?") % item.class.name),
              :fail_msg => (_("Assign openscap_proxy to %s before proceeding.") % item.name)
            ).fail!
          )
        end
      end

      def model_to_s(model)
        model.is_a?(::Hostgroup) ? 'hostgroup' : 'host'
      end

      def model_to_check(model)
        check = SetupCheck.new(
          :title => (_("Was %{model_name} %{name} configured successfully?") % { :model_name => model_to_s(model), :name => model.name }),
          :errors => model.errors.to_h
        )
        model.errors.any? ? check.fail! : check.pass!
      end
    end
  end
end
