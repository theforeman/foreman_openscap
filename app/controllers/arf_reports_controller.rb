class ArfReportsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def model_of_controller
    ::Scaptimony::ArfReport
  end

  # GET /arf_reports
  def index
    @arf_reports = resource_base.search_for(params[:search])
  end
end
