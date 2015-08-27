class ComplianceHostsController < ApplicationController
  def show
    @host = Host.find(params[:id])
  end
end
