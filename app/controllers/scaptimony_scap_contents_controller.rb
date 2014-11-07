class ScaptimonyScapContentsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def model_of_controller
    ::Scaptimony::ScapContent
  end

  # GET /scaptimony_scap_contents
  def index
    @contents = resource_base.search_for(params[:search])
  end
end
