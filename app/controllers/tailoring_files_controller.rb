class TailoringFilesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include Foreman::Controller::Parameters::TailoringFile

  before_action :find_tailoring_file, :only => %i[destroy update edit xml]
  before_action :handle_file_upload, :only => %i[create update]

  def model_of_controller
    ::ForemanOpenscap::TailoringFile
  end

  def index
    @tailoring_files = resource_base.search_for(params[:search], :order => params[:order])
                                    .paginate(:page => params[:page], :per_page => params[:per_page])
  end

  def new
    @tailoring_file = ::ForemanOpenscap::TailoringFile.new
  end

  def create
    @tailoring_file = ForemanOpenscap::TailoringFile.new(tailoring_file_params)
    if @tailoring_file.save
      process_success
    else
      process_error
    end
  end

  def edit
  end

  def update
    if @tailoring_file.update_attributes(tailoring_file_params)
      process_success
    else
      process_error
    end
  end

  def destroy
    if @tailoring_file.destroy
      process_success
    else
      process_error :object => @tailoring_file
    end
  end

  def xml
    send_data @tailoring_file.scap_file,
              :type     => 'application/xml',
              :filename => @tailoring_file.original_filename || "#{@tailoring_file.name}.xml"
  end

  private

  def find_tailoring_file
    @tailoring_file = resource_base.find(params[:id])
  end

  def handle_file_upload
    return unless params[:tailoring_file] && raw_file = params[:tailoring_file][:scap_file]
    params[:tailoring_file][:original_filename] = raw_file.original_filename
    params[:tailoring_file][:scap_file] = raw_file.tempfile.read if raw_file.respond_to?(:tempfile) && raw_file.tempfile.respond_to?(:read)
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
