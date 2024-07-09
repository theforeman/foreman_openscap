module Api::V2
  module Compliance
    class TailoringFilesController < ::Api::V2::BaseController
      include Foreman::Controller::Parameters::TailoringFile
      include ForemanOpenscap::BodyLogExtensions
      include ForemanOpenscap::Api::V2::ScapApiControllerExtensions

      before_action :find_resource, :except => %w[index create]

      api :GET, '/compliance/tailoring_files', N_('List Tailoring files')
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(::ForemanOpenscap::TailoringFile)

      def index
        @tailoring_files = resource_scope_for_index(:permission => :view_tailoring_files)
      end

      api :GET, '/compliance/tailoring_files/:id/xml', N_('Download a Tailoring file as XML')
      param :id, :identifier, :required => true

      def xml
        send_data @tailoring_file.scap_file,
                  :type     => 'application/xml',
                  :filename => @tailoring_file.original_filename || "#{@tailoring_file.name}.xml"
      end

      api :GET, '/compliance/tailoring_files/:id', N_('Show a Tailoring file')
      param :id, :identifier, :required => true
      def show
      end

      def_param_group :tailoring_file do
        param :tailoring_file, Hash, :required => true, :action_aware => true do
          param :name, String, :required => true, :desc => N_('Tailoring file name')
          param :scap_file, String, :required => true, :desc => N_('XML containing tailoring file')
          param :original_filename, String, :desc => N_('Original file name of the XML file')
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, '/compliance/tailoring_files', N_('Create a Tailoring file')
      param_group :tailoring_file, :as => :create

      def create
        @tailoring_file = ForemanOpenscap::TailoringFile.new(tailoring_file_params)
        process_response @tailoring_file.save
      end

      api :PUT, '/compliance/tailoring_files/:id', N_('Update a Tailoring file')
      param :id, :identifier, :required => true
      param_group :tailoring_file

      def update
        process_response @tailoring_file.update(tailoring_file_params)
      end

      api :DELETE, '/compliance/tailoring_files/:id', N_('Deletes a Tailoring file')
      param :id, :identifier, :required => true

      def destroy
        process_response @tailoring_file.destroy
      end

      private

      def find_resource
        not_found && return if params[:id].blank?
        instance_variable_set("@tailoring_file", resource_scope.find(params[:id]))
      end

      def action_permission
        case params[:action]
        when 'xml'
          :view
        else
          super
        end
      end
    end
  end
end
