module Api::V2
  module Compliance
    class PoliciesController < ::Api::V2::BaseController
      before_filter :find_resource, :except => %w{index create}

      def resource_name
        'Scaptimony::Policy'
      end

      def get_resource
        instance_variable_get :"@policy" or raise 'no resource loaded'
      end

      def policy_url(policy = nil)
        api_policy_url(@policy)
      end

      resource_description do
        resource_id 'scaptimony_policies'
        api_version 'v2'
        api_base_url "/api/v2"
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
          param :scap_content_id, Integer, :required => true, :desc => N_('Policy scap content id')
          param :scap_content_profile_id, Integer, :required => true, :desc => N_('Policy scap content profile id')
          param :period, String, :required => true, :desc => N_('Policy schedule period')
          param :weekday, String, :required => true, :desc => N_('Policy schedule weekday')
          param :hostgroup_ids, Array, :desc => N_('Apply policy to hostgroups')
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, '/compliance/policies', N_('Create a policy')
      param_group :policy, :as => :create

      def create
        @policy = Scaptimony::Policy.new(params[:policy])
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

      private
      def find_resource
        not_found and return if params[:id].blank?
        instance_variable_set("@policy", resource_scope.find(params[:id]))
      end
    end
  end
end
