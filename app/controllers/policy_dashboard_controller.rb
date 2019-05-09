class PolicyDashboardController < ApplicationController
  before_action :prefetch_data, :only => :index

  def index
  end

  def prefetch_data
    @policy = ::ForemanOpenscap::Policy.find(params[:id])
    dashboard = ForemanOpenscap::PolicyDashboard::Data.new(@policy, params[:search])
    @report = dashboard.report
    @latest_reports = ForemanOpenscap::ArfReport
                      .includes(:host)
                      .of_policy(@policy.id)
                      .latest
                      .paginate(:page => params[:page], :per_page => params[:per_page])
  end
end
