class ScaptimonyArfReportsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :find_by_id, :only => [:show, :parse, :destroy]

  def model_of_controller
    ::Scaptimony::ArfReport
  end

  def index
    @arf_reports = resource_base.includes(:arf_report_breakdown, :asset ,:host)
      .search_for(params[:search], :order => params[:order])
      .paginate(:page => params[:page], :per_page => params[:per_page])
  end

  def show
  end

  def parse
    self.response_body = @arf_report.to_html
  end

  def destroy
    if @arf_report.destroy
      process_success
    else
      process_error
    end
  end

  def find_by_id
    @arf_report = resource_base.find(params[:id])
  end
end
