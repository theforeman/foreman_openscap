class OpenscapProxiesController < ApplicationController
  before_action :find_proxy, :only => [:openscap_spool]

  def openscap_spool
    last_error = @smart_proxy ? find_spool_error : nil
    render :partial => 'smart_proxies/openscap_spool', :locals => { :last_error => last_error }
  end

  private

  def action_permission
    case params[:action]
    when 'openscap_spool'
      :view
    else
      super
    end
  end

  def find_proxy
    @smart_proxy = SmartProxy.find params[:id]
  end

  def find_spool_error
    log_status = @smart_proxy.statuses[:logs]
    return {} unless log_status
    log_status.logs
              .log_entries
              .reverse
              .find { |entry| entry["level"] == "ERROR" && entry["message"].start_with?("Failed to parse Arf Report") }
  end
end
