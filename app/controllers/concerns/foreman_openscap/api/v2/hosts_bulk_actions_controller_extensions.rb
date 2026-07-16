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
                message: _("No OpenSCAP Capsule selected."),
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
                message: _("OpenSCAP Capsule with id %s not found") % openscap_proxy_id,
              },
            }, status: :unprocessable_entity
          end

          unless smart_proxy.has_feature?('Openscap')
            return render json: {
              error: {
                message: _("The selected capsule does not have the OpenSCAP feature enabled."),
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
              message: _("OpenSCAP Capsule set to %s") % smart_proxy.name,
            })
          else
            render_error(:bulk_hosts_error, status: :unprocessable_entity,
                         locals: {
                           message: n_("Failed to assign OpenSCAP Capsule to %s host",
                                       "Failed to assign OpenSCAP Capsule to %s hosts",
                                       failed_hosts.count) % failed_hosts.count,
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
