module Api::V2
  module Compliance
    class PoliciesController < ::Api::V2::BaseController
      include Foreman::Controller::SmartProxyAuth
      include Foreman::Controller::Parameters::PolicyApi

      add_smart_proxy_filters %i[content tailoring], :features => 'Openscap'

      before_filter :find_resource, :except => %w[index create]

      skip_after_filter :log_response_body, :only => [:content]

      def resource_name
        '::ForemanOpenscap::Policy'
      end

      def get_resource(message = 'no resource loaded')
        instance_variable_get(:"@policy") || raise(message)
      end

      def policy_url(policy = nil)
        api_compliance_policy_url(@policy)
      end

      api :GET, '/compliance/policies', N_('List Policies')
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @policies = resource_scope_for_index(:permission => :view_policies)
      end

      api :GET, '/compliance/policies/:id', N_('Show a Policy')
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :policy do
        param :policy, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_('Policy name')
          param :description, String, :desc => N_('Policy description')
          param :scap_content_id, Integer, :required => true, :desc => N_('Policy SCAP content ID')
          param :scap_content_profile_id, Integer, :required => true, :desc => N_('Policy SCAP content profile ID')
          param :period, String, :desc => N_('Policy schedule period (weekly, monthly, custom)')
          param :weekday, String, :desc => N_('Policy schedule weekday (only if period == "weekly")')
          param :day_of_month, Integer, :desc => N_('Policy schedule day of month (only if period == "monthly")')
          param :cron_line, String, :desc => N_('Policy schedule cron line (only if period == "custom")')
          param :hostgroup_ids, Array, :desc => N_('Apply policy to host groups')
          param :tailoring_file_id, Integer, :desc => N_('Tailoring file ID')
          param :tailoring_file_profile_id, Integer, :desc => N_('Tailoring file profile ID')
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, '/compliance/policies', N_('Create a Policy')
      param_group :policy, :as => :create

      def create
        @policy = ForemanOpenscap::Policy.new(policy_params)
        process_response @policy.save
      end

      api :PUT, '/compliance/policies/:id', N_('Update a Policy')
      param :id, :identifier, :required => true
      param_group :policy

      def update
        process_response @policy.update_attributes(policy_params)
      end

      api :DELETE, '/compliance/policies/:id', N_('Delete a Policy')
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

      api :GET, '/compliance/policies/:id/tailoring', N_("Show a policy's Tailoring file")
      param :id, :identifier, :required => true

      def tailoring
        @tailoring_file = @policy.tailoring_file
        if @tailoring_file
          send_data @tailoring_file.scap_file,
                    :type => 'application/xml',
                    :filename => @tailoring_file.original_filename
        else
          render(:json => { :error => { :message => _("No Tailoring file assigned for policy with id %s") % @policy.id } }, :status => 404)
        end
      end

      private

      def find_resource
        not_found && return if params[:id].blank?
        instance_variable_set("@policy", resource_scope.find(params[:id]))
      end

      def action_permission
        case params[:action]
        when 'content', 'tailoring'
          :view
        else
          super
        end
      end
    end
  end
end
