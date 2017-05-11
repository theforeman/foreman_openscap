class PolicyDashboardController < ApplicationController
  before_filter :prefetch_data, :only => :index

  def index
  end

  def prefetch_data
    @policy = ::ForemanOpenscap::Policy.find(params[:id])
    dashboard = ForemanOpenscap::PolicyDashboard::Data.new(@policy, params[:search])
    @report = dashboard.report
  end
end
