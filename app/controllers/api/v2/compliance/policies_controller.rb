module Api::V2
  module Compliance
    class PoliciesController < ::Api::V2::BaseController
      include Api::Version2
      include Foreman::Controller::SmartProxyAuth

      # add_puppetmaster_filters :create

      skip_before_filter :require_login, :only => :content
      skip_before_filter :require_ssl, :only => :content
      skip_before_filter :authorize, :only => :content
      skip_before_filter :verify_authenticity_token, :only => :content
      skip_before_filter :set_taxonomy, :only => :content
      skip_before_filter :session_expiry, :update_activity_time, :only => :content

      before_filter :find_resource, :only => %w{content}

      attr_reader :detected_proxy

      def resource_name
        'Scaptimony::Policy'
      end

      def get_resource
        instance_variable_get :"@policy" or raise 'no resource loaded'
      end

      resource_description do
        resource_id 'scaptimony_policies'
        api_version 'v2'
        api_base_url "/api/v2"
      end

      api :GET, '/compliance/policies/:id/content', N_("Show a policy's SCAP content")
      param :id, :identifier, :required => true

      def content
        @scap_content = @policy.scap_content
        send_file @scap_content.scap_file,
                  :type     => 'application/xml',
                  :filename => @scap_content.original_filename
      end

      private
      def find_resource
        not_found and return if params[:id].blank?
        instance_variable_set("@policy", Scaptimony::Policy.find(params[:id]))
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
