class OpenscapProxiesController < ApplicationController
  before_action :find_proxy, :only => [:openscap_spool]

  def openscap_spool
    spool_errors = @smart_proxy ? @smart_proxy.statuses[:openscap].spool_status : nil
    render :partial => 'smart_proxies/openscap_spool', :locals => { :spool_errors => spool_errors }
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
end
