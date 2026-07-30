module Api::V2
  module Compliance
    class HostsBulkActionsController < ::Api::V2::BaseController
      include Api::Version2
      include Api::V2::BulkHostsExtension

      before_action :find_editable_hosts, only: [:change_openscap_proxy]
      before_action :validate_openscap_proxy_id, only: [:change_openscap_proxy]
      before_action :find_openscap_proxy, only: [:change_openscap_proxy]
      before_action :validate_openscap_proxy_feature, only: [:change_openscap_proxy]

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

      api :PUT, "/hosts/bulk/change_openscap_proxy", N_("Assign OpenSCAP Proxy to multiple hosts")
      param_group :bulk_host_ids
      param :openscap_proxy_id, :number, :required => true, :desc => N_("ID of the OpenSCAP Proxy to assign to the hosts")
      def change_openscap_proxy
        failed_hosts = []
        @hosts.each do |host|
          host.openscap_proxy = @smart_proxy
          failed_hosts << host unless host.save
        end

        if failed_hosts.empty?
          message = _("OpenSCAP Proxy is set to %s") % @smart_proxy.name
          process_response(true, {
            :message => n_("Updated host: #{message}", "Updated hosts: #{message}", @hosts.count),
          })
        else
          total_count = @hosts.size
          failed_count = failed_hosts.size
          success_count = total_count - failed_count

          parts = [
            n_("Failed to assign OpenSCAP Proxy to %{failed} of %{total} host.",
               "Failed to assign OpenSCAP Proxy to %{failed} of %{total} hosts.",
               total_count) % { failed: failed_count, total: total_count },
          ]
          if success_count > 0
            parts << n_("Successfully updated %{success} host.",
                        "Successfully updated %{success} hosts.",
                        success_count) % { success: success_count }
          end

          render_error(:bulk_hosts_error, status: :unprocessable_entity,
                       locals: {
                         :message => parts.join(' '),
                         :failed_host_ids => failed_hosts.map(&:id),
                       })
        end
      end

      private

      def find_editable_hosts
        find_bulk_hosts(:edit_hosts, params)
      end

      def validate_openscap_proxy_id
        return if params[:openscap_proxy_id].present?

        render json: {
          :error => {
            :message => _("No OpenSCAP Proxy selected."),
          },
        }, :status => :unprocessable_entity
      end

      def find_openscap_proxy
        @smart_proxy = ::SmartProxy.find_by(:id => params[:openscap_proxy_id])
        return if @smart_proxy

        render json: {
          :error => {
            :message => _("OpenSCAP Proxy with id %s not found") % params[:openscap_proxy_id],
          },
        }, :status => :unprocessable_entity
      end

      def validate_openscap_proxy_feature
        return if @smart_proxy.has_feature?('Openscap')

        render json: {
          :error => {
            :message => _("The selected OpenSCAP Proxy does not have the OpenSCAP feature enabled."),
          },
        }, :status => :unprocessable_entity
      end
    end
  end
end
