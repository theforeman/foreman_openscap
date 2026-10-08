module Api::V2
  module Compliance
    class HostsBulkActionsController < ::Api::V2::BaseController
      include Api::V2::BulkHostsExtension

      rescue_from ActionController::ParameterMissing do |exception|
        render_error(:custom_error, :status => :unprocessable_entity, :locals => { :message => exception.message })
      end

      before_action :find_editable_hosts, only: [:change_openscap_proxy, :assign_compliance_policy, :unassign_compliance_policy]
      before_action :find_openscap_proxy, only: [:change_openscap_proxy]
      before_action :validate_openscap_proxy_feature, only: [:change_openscap_proxy]
      before_action :find_compliance_policy, only: [:assign_compliance_policy, :unassign_compliance_policy]

      def_param_group :bulk_host_ids do
        param :included, Hash, :desc => N_("Hosts to include in the action"), :required => true, :action_aware => true do
          param :search, String, :required => false, :desc => N_("Search string describing which hosts to perform the action on")
          param :ids, Array, :required => false, :desc => N_("List of host ids to perform the action on")
        end
        param :excluded, Hash, :desc => N_("Hosts to explicitly exclude in the action."\
                                           " All other hosts will be included in the action,"\
                                           " unless an included parameter is passed as well."), :required => true, :action_aware => true do
          param :ids, Array, :required => false, :desc => N_("List of host ids to exclude and not perform the action on")
        end
      end

      api :PUT, "/compliance/hosts/bulk/assign_compliance_policy", N_("Assign compliance policy to multiple hosts")
      param_group :bulk_host_ids
      param :policy_id, :number, :required => true, :desc => N_("ID of the compliance policy to assign to the hosts")
      def assign_compliance_policy
        @policy.host_ids = @policy.host_ids + @hosts.pluck(:id)
        if @policy.save
          message = _("Assigned with compliance policy: %s") % @policy.name
          process_response(true, {
            :message => n_("Updated host: #{message}", "Updated hosts: #{message}", @hosts.count),
          })
        else
          render_error(:custom_error, :status => :unprocessable_entity,
                       :locals => { :message => @policy.errors.full_messages.to_sentence })
        end
      end

      api :PUT, "/compliance/hosts/bulk/unassign_compliance_policy", N_("Unassign compliance policy from multiple hosts")
      param_group :bulk_host_ids
      param :policy_id, :number, :required => true, :desc => N_("ID of the compliance policy to unassign from the hosts")
      def unassign_compliance_policy
        if @policy.unassign_hosts(@hosts)
          message = _("Unassigned from compliance policy '%s'") % @policy.name
          process_response(true, {
            :message => n_("Updated host: #{message}", "Updated hosts: #{message}", @hosts.count),
          })
        else
          render_error(:custom_error, :status => :unprocessable_entity,
                       :locals => { :message => @policy.errors.full_messages.to_sentence })
        end
      end

      api :PUT, "/hosts/bulk/change_openscap_proxy", N_("Assign OpenSCAP Proxy to multiple hosts")
      param_group :bulk_host_ids
      param :openscap_proxy_id, :number, :required => true, :desc => N_("ID of the OpenSCAP Proxy to assign to the hosts")
      def change_openscap_proxy
        failed_host_ids = []
        host_count = @hosts.count

        @hosts.find_each do |host|
          host.openscap_proxy = @smart_proxy
          failed_host_ids << host.id unless host.save
        end

        if failed_host_ids.empty?
          message = _("OpenSCAP Proxy is set to %s") % @smart_proxy.name
          process_response(true, {
            :message => n_("Updated host: #{message}", "Updated hosts: #{message}", host_count),
          })
        else
          failed_count = failed_host_ids.size
          success_count = host_count - failed_count

          parts = [
            n_("Failed to assign OpenSCAP Proxy to %{failed} of %{total} host.",
               "Failed to assign OpenSCAP Proxy to %{failed} of %{total} hosts.",
               host_count) % { failed: failed_count, total: host_count },
          ]
          if success_count > 0
            parts << n_("Successfully updated %{success} host.",
                        "Successfully updated %{success} hosts.",
                        success_count) % { success: success_count }
          end

          render_error(:bulk_hosts_error, :status => :unprocessable_entity,
                       :locals => {
                         :message => parts.join(' '),
                         :failed_host_ids => failed_host_ids,
                       })
        end
      end

      private

      def find_editable_hosts
        find_bulk_hosts(:edit_hosts, params)
      end

      def find_openscap_proxy
        @smart_proxy = ::SmartProxy.authorized(:view_smart_proxies)
          .find_by(:id => params.require(:openscap_proxy_id))
        return if @smart_proxy

        render_error(:custom_error, :status => :unprocessable_entity,
                     :locals => { :message => _("OpenSCAP Proxy with id %s not found") % params[:openscap_proxy_id] })
      end

      def validate_openscap_proxy_feature
        return if @smart_proxy.has_feature?('Openscap')

        render_error(:custom_error, :status => :unprocessable_entity,
                     :locals => { :message => _("The selected OpenSCAP Proxy does not have the OpenSCAP feature enabled.") })
      end

      def find_compliance_policy
        @policy = ::ForemanOpenscap::Policy.authorized(:assign_policies)
          .find_by(:id => params.require(:policy_id))
        return if @policy

        render_error(:custom_error, :status => :unprocessable_entity,
                     :locals => { :message => _("Compliance policy with id %s not found") % params[:policy_id] })
      end
    end
  end
end
