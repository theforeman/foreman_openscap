class ScaptimonyPoliciesController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  def model_of_controller
    ::Scaptimony::Policy
  end

  # GET /scaptimony_policies
  def index
    @policies = resource_base.search_for(params[:search])
  end

  def new
    @policy = ::Scaptimony::Policy.new
  end

  def create
    @policy = ::Scaptimony::Policy.new(params[:policy])
    if @policy.save
      process_success
    else
      process_error
    end
  end
end
