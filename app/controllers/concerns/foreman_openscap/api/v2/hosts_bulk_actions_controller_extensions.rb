module ForemanOpenscap
  module Api
    module V2
      module HostsBulkActionsControllerExtensions
        extend ActiveSupport::Concern

        included do
          before_action :find_editable_hosts, only: [:change_openscap_proxy]
        end

        def change_openscap_proxy
          openscap_proxy_id = params[:openscap_proxy_id]

          if openscap_proxy_id.blank?
            return render json: {
              error: {
                message: _("No OpenSCAP Proxy selected."),
              },
            }, status: :unprocessable_entity
          end

          smart_proxy = begin
            ::SmartProxy.find(openscap_proxy_id)
          rescue ActiveRecord::RecordNotFound
            nil
          end

          if smart_proxy.nil?
            return render json: {
              error: {
                message: _("OpenSCAP proxy with id %s not found") % openscap_proxy_id,
              },
            }, status: :unprocessable_entity
          end

          unless smart_proxy.has_feature?('Openscap')
            return render json: {
              error: {
                message: _("The selected proxy does not have the OpenSCAP feature enabled."),
              },
            }, status: :unprocessable_entity
          end

          failed_hosts = []
          @hosts.each do |host|
            host.openscap_proxy = smart_proxy
            failed_hosts << host unless host.save
          end

          if failed_hosts.empty?
            process_response(true, {
              message: _("OpenSCAP Proxy set to %s") % smart_proxy.name,
            })
          else
            total_count = @hosts.count
            failed_count = failed_hosts.count
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
                           message: parts.join(' '),
                           failed_host_ids: failed_hosts.map(&:id),
                         })
          end
        end

        private

        def action_permission
          case params[:action]
          when 'change_openscap_proxy'
            'edit'
          else
            super
          end
        end
      end
    end
  end
end
