module Api::V2
  module Compliance
    class PoliciesController < ::Api::V2::BaseController
      before_filter :find_resource, :only => %w{content}

      def resource_name
        'Scaptimony::Policy'
      end

      def get_resource
        instance_variable_get :"@policy" or raise 'no resource loaded'
      end

      api :GET, '/compliance/policies/:id/content', N_("Show a policy's SCAP content")
      param :id, :identifier, :required => true

      def content
        @scap_content = @policy.scap_content
        send_data @scap_content.scap_file,
                  :type     => 'application/xml',
                  :filename => @scap_content.original_filename
      end

      private
      def find_resource
        not_found and return if params[:id].blank?
        instance_variable_set("@policy", resource_scope.find(params[:id]))
      end

      def action_permission
        case params[:action]
          when 'content'
            :view
          else
            super
        end
      end
    end
  end
end
