module Api::V2
  module Compliance
    class ScapContentsController < ::Api::V2::BaseController
      before_filter :find_resource, :except => %w{index create}

      def resource_name
        'Scaptimony::ScapContent'
      end

      def get_resource
        instance_variable_get :"@scap_content" or raise 'no resource loaded'
      end

      resource_description do
        resource_id 'scaptimony_scap_contents'
        api_version 'v2'
        api_base_url "/api/v2"
      end

      api :GET, '/compliance/scap_contents', N_('List SCAP contents')
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @scap_contents = resource_scope_for_index(:permission => :edit_compliance)
      end

      api :GET, '/compliance/scap_contents/:id', N_('Show an SCAP content')
      param :id, :identifier, :required => true

      def show
        send_data @scap_content.scap_file,
                  :type     => 'application/xml',
                  :filename => @scap_content.original_filename
      end

      def_param_group :scap_content do
        param :scap_content, Hash, :required => true, :action_aware => true do
          param :title, String, :required => true, :desc => N_('Scap content name')
          param :scap_file, String, :required => true
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, '/compliance/scap_contents', N_('Create SCAP content')
      param_group :scap_content, :as => :create

      def create
        @scap_content = Scaptimony::ScapContent.new(params[:scap_content])
        process_response @scap_content.save
      end

      api :PUT, '/compliance/scap_contents/:id', N_('Update an SCAP content')
      param :id, :identifier, :required => true
      param_group :scap_content

      def update
        process_response @scap_content.update_attributes(params[:scap_content])
      end

      api :DELETE, '/compliance/scap_contents/:id', N_('Deletes an SCAP content')
      param :id, :identifier, :required => true

      def destroy
        process_response @scap_content.destroy
      end

      private
      def find_resource
        not_found and return if params[:id].blank?
        instance_variable_set("@scap_content", resource_scope.find(params[:id]))
      end
    end
  end
end
