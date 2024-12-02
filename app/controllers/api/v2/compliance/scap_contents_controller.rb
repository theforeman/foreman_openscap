module Api::V2
  module Compliance
    class ScapContentsController < ::Api::V2::BaseController
      include Foreman::Controller::Parameters::ScapContent
      include ForemanOpenscap::BodyLogExtensions
      include ForemanOpenscap::Api::V2::ScapApiControllerExtensions

      def self.bulk_upload_types
        ['files', 'directory', 'default']
      end

      before_action :find_resource, :except => %w[index create bulk_upload]

      api :GET, '/compliance/scap_contents', N_('List SCAP contents')
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(::ForemanOpenscap::ScapContent)

      def index
        @scap_contents = resource_scope_for_index(:permission => :view_scap_contents)
      end

      api :GET, '/compliance/scap_contents/:id/xml', N_('Download an SCAP content as XML')
      param :id, :identifier, :required => true

      def xml
        send_data @scap_content.scap_file,
                  :type     => 'application/xml',
                  :filename => @scap_content.original_filename || "#{@scap_content.title}.xml"
      end

      api :GET, '/compliance/scap_contents/:id', N_('Show an SCAP content')
      param :id, :identifier, :required => true
      def show
      end

      def_param_group :scap_content do
        param :scap_content, Hash, :required => true, :action_aware => true do
          param :title, String, :required => true, :desc => N_('SCAP content name')
          param :scap_file, String, :required => true, :desc => N_('XML containing SCAP content')
          param :original_filename, String, :desc => N_('Original file name of the XML file')
          param_group :taxonomies, ::Api::V2::BaseController
        end
      end

      api :POST, '/compliance/scap_contents', N_('Create SCAP content')
      param_group :scap_content, :as => :create

      def create
        @scap_content = ForemanOpenscap::ScapContent.new(scap_content_params)
        process_response @scap_content.save
      end

      api :PUT, '/compliance/scap_contents/:id', N_('Update an SCAP content')
      param :id, :identifier, :required => true
      param_group :scap_content

      def update
        process_response @scap_content.update(scap_content_params)
      end

      api :DELETE, '/compliance/scap_contents/:id', N_('Deletes an SCAP content')
      param :id, :identifier, :required => true

      def destroy
        process_response @scap_content.destroy
      end

      api :POST, '/compliance/scap_contents/bulk_upload', N_('Upload scap contents in bulk')
      param :type, bulk_upload_types, :required => true, :desc => N_('Type of the upload')
      param :files, Array, :desc => N_('File paths to upload when using "files" upload type')
      param :directory, String, :desc => N_('Directory to upload when using "directory" upload type')

      def bulk_upload
        case params[:type]
        when 'files'
          @result = ForemanOpenscap::BulkUpload.new.upload_from_files(params[:files])
        when 'directory'
          @result = ForemanOpenscap::BulkUpload.new.upload_from_directory(params[:directory])
        when 'default'
          @result = ForemanOpenscap::BulkUpload.new.upload_from_scap_guide
        else
          return render :json => {
            :errors => [
              _("Please specify import type, received: %{received}, expected one of: %{expected}") %
                { :expected => self.class.bulk_upload_types.join(', '), :received => params[:type] }
            ]
          }, :status => :unprocessable_entity
        end
      end

      private

      def find_resource
        not_found && return if params[:id].blank?
        instance_variable_set("@scap_content", resource_scope.find(params[:id]))
      end

      def action_permission
        case params[:action]
        when 'bulk_upload'
          :create
        when 'xml'
          :view
        else
          super
        end
      end
    end
  end
end
