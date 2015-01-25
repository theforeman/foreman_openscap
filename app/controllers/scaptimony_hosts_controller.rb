class ScaptimonyHostsController < ApplicationController
  def show
    @host = Host.find(params[:id])
  end
end