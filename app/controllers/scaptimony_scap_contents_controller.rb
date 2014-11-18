class ScaptimonyScapContentsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :handle_file_upload, :only => [:create]
  before_filter :find_by_id, :only => [:show, :edit, :update]

  def model_of_controller
    ::Scaptimony::ScapContent
  end

  # GET /scaptimony_scap_contents
  def index
    @contents = resource_base.search_for(params[:search])
  end

  def show
    send_file @scaptimony_scap_content.path,
      :type => "application/xml",
      :filename => @scaptimony_scap_content.original_filename
  end

  def new
    @scaptimony_scap_content = ::Scaptimony::ScapContent.new
  end

  # POST /scaptimony_scap_contents
  def create
    @scaptimony_scap_content = ::Scaptimony::ScapContent.new(params[:scap_content])
    if @scaptimony_scap_content.store
      process_success :success_redirect => scaptimony_scap_contents_path
    else
      process_error
    end
  end

  def handle_file_upload
    return unless params[:scap_content] and
       t = params[:scap_content][:scap_file]
    params[:scap_content][:original_filename] = t.original_filename
    params[:scap_content][:scap_file] = t.read if t.respond_to?(:read)
  end

  def update
    if @scaptimony_scap_content.update_attributes(params[:scap_content])
      process_success :success_redirect => scaptimony_scap_contents_path
    else
      process_error
    end
  end

  private
  def find_by_id
    @scaptimony_scap_content = resource_base.find(params[:id])
  end
end
