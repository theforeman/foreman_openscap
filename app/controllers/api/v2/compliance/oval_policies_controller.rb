module Api::V2
  module Compliance
    class OvalPoliciesController < ::Api::V2::BaseController
      include ForemanOpenscap::Api::V2::ScapApiControllerExtensions
      include Foreman::Controller::Parameters::OvalPolicy

      before_action :find_resource, :except => %w[index create]

      api :GET, '/compliance/oval_policies', N_('List OVAL Policies')
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @oval_policies = resource_scope_for_index(:permission => :view_oval_policies)
      end

      api :GET, '/compliance/oval_policies/:id', N_('Show an OVAL Policy')
      param :id, :identifier, :required => true

      def show
      end

      def_param_group :oval_policy do
        param :oval_policy, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_('OVAL Policy name')
          param :oval_content_id, Integer, :required => true, :desc => N_('Policy OVAL content ID')
          param :description, String, :desc => N_('OVAL Policy description')
          param :period, String, :desc => N_('OVAL Policy schedule period (weekly, monthly, custom)')
          param :weekday, String, :desc => N_('OVAL Policy schedule weekday (only if period == "weekly")')
          param :day_of_month, Integer, :desc => N_('OVAL Policy schedule day of month (only if period == "monthly")')
          param :cron_line, String, :desc => N_('OVAL Policy schedule cron line (only if period == "custom")')
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, '/compliance/oval_policies', N_('Create an OVAL Policy')
      param_group :oval_policy, :as => :create

      def create
        @oval_policy = ForemanOpenscap::OvalPolicy.new(oval_policy_params)
        process_response(@oval_policy.save)
      end

      api :PUT, '/compliance/oval_policies/:id', N_('Update an OVAL Policy')
      param :id, :identifier, :required => true
      param_group :oval_policy

      def update
        process_response(@oval_policy.update(oval_policy_params))
      end

      api :DELETE, '/compliance/oval_policies/:id', N_('Delete an OVAL Policy')
      param :id, :identifier, :required => true

      def destroy
        process_response @oval_policy.destroy
      end
    end
  end
end
