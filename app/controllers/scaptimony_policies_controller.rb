class ScaptimonyPoliciesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def model_of_controller
    ::Scaptimony::Policy
  end

  # GET /scaptimony_policies
  def index
    @policies = resource_base.search_for(params[:search])
  end
end
