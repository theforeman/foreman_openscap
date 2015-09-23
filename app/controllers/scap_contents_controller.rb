class ScapContentsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  before_filter :handle_file_upload, :only => [:create, :update]
  before_filter :find_by_id, :only => [:show, :edit, :update, :destroy]

  def model_of_controller
    ::ForemanOpenscap::ScapContent
  end

  def index
    @contents = resource_base.search_for(params[:search])
  end

  def show
    send_data @scap_content.scap_file,
      :type     => 'application/xml',
      :filename => @scap_content.original_filename
  end

  def new
    @scap_content = ForemanOpenscap::ScapContent.new
  end

  def create
    @scap_content = ForemanOpenscap::ScapContent.new(params[:scap_content])
    if @scap_content.save
      process_success
    else
      process_error
    end
  end

  def update
    if @scap_content.update_attributes(params[:scap_content])
      process_success
    else
      process_error
    end
  end

  def destroy
    if @scap_content.destroy
      process_success
    else
      process_error :object => @scap_content
    end
  end

  def welcome
    @searchbar = true
    if (model_of_controller.first.nil? rescue false)
      @searchbar = false
      render :welcome rescue nil and return
    end
  rescue
    not_found
  end

  private
  def find_by_id
    @scap_content = resource_base.find(params[:id])
  end

  def handle_file_upload
    return unless params[:scap_content] && scap_raw_file = params[:scap_content][:scap_file]
    params[:scap_content][:original_filename] = scap_raw_file.original_filename
    params[:scap_content][:scap_file] = scap_raw_file.tempfile.read if scap_raw_file.tempfile.respond_to?(:read)
  end

end
