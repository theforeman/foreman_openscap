module ForemanRadiator
  class DashboardController < ::ApplicationController

    layout 'foreman_radiator/layouts/application_radiator'

    def radiator
      dashboard = Dashboard.new(params[:search])
      @hosts    = dashboard.hosts
      @report   = dashboard.report

      if @report[:total_hosts] > 0
	      @perc_unresponsive =  "#{(100 * @report[:reports_missing] / @report[:total_hosts]).to_i}%"
	      @perc_failed =  "#{(100 * @report[:bad_hosts_enabled] / @report[:total_hosts]).to_i}%"
	      @perc_pending =  "#{(100 * @report[:pending_hosts_enabled] / @report[:total_hosts]).to_i}%"
	      @perc_changed =  "#{(100 * @report[:active_hosts_ok_enabled] / @report[:total_hosts]).to_i}%"
	      @perc_unchanged =  "#{(100 * @report[:ok_hosts_enabled] / @report[:total_hosts]).to_i}%"
	      @perc_unreported =  "#{(100 * @report[:out_of_sync_hosts_enabled] / @report[:total_hosts]).to_i}%"
	  end

    end


 end
end
