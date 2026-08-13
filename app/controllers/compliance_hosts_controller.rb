class ComplianceHostsController < ApplicationController
  def model_of_controller
    Host
  end

  def show
    @host = resource_base.find(params[:id])
  end
end
