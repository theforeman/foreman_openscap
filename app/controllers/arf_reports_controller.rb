class ArfReportsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :find_by_id, :only => [:show]

  def model_of_controller
    ::Scaptimony::ArfReport
  end

  # GET /arf_reports
  def index
    @arf_reports = resource_base.search_for(params[:search])
  end

  # GET /arf_reports/1
  def show
    self.response_body = @arf_report
  end

  def find_by_id
    @arf_report = resource_base.find(params[:id])
  end
end
