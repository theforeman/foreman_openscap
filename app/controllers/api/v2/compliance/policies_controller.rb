module Api::V2
  module Compliance
    class PoliciesController < ::Api::V2::BaseController
      include Foreman::Controller::SmartProxyAuth

      add_smart_proxy_filters :content, :features => 'Openscap'

      before_filter :find_resource, :except => %w(index create)

      skip_after_filter :log_response_body, :only => [:content]

      def resource_name
        '::ForemanOpenscap::Policy'
      end

      def get_resource
        instance_variable_get :"@policy" or fail 'no resource loaded'
      end

      def policy_url(policy = nil)
        api_compliance_policy_url(@policy)
      end

      api :GET, '/compliance/policies', N_('List SCAP contents')
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @policies = resource_scope_for_index(:permission => :edit_compliance)
      end

      api :GET, '/compliance/policies/:id', N_('Show an SCAP content')
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :policy do
        param :policy, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_('Policy name')
          param :description, String, :desc => N_('Policy description')
          param :scap_content_id, Integer, :required => true, :desc => N_('Policy SCAP content ID')
          param :scap_content_profile_id, Integer, :required => true, :desc => N_('Policy SCAP content profile ID')
          param :period, String, :desc => N_('Policy schedule period')
          param :weekday, String, :desc => N_('Policy schedule weekday')
          param :day_of_month, Integer, :desc => N_('Policy schedule day of month')
          param :cron_line, String, :desc => N_('Policy schedule cron line')
          param :hostgroup_ids, Array, :desc => N_('Apply policy to host groups')
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, '/compliance/policies', N_('Create a policy')
      param_group :policy, :as => :create

      def create
        @policy = ForemanOpenscap::Policy.new(params[:policy])
        process_response @policy.save
      end

      api :PUT, '/compliance/policies/:id', N_('Update a policy')
      param :id, :identifier, :required => true
      param_group :policy

      def update
        process_response @policy.update_attributes(params[:policy])
      end

      api :DELETE, '/compliance/policies/:id', N_('Deletes a policy')
      param :id, :identifier, :required => true

      def destroy
        process_response @policy.destroy
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
