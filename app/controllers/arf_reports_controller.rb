class ArfReportsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch
  include ForemanOpenscap::ArfReportsControllerCommonExtensions

  before_action :find_arf_report, :only => %i[show show_html destroy parse_html parse_bzip download_html]
  before_action :find_multiple, :only => %i[delete_multiple submit_delete_multiple]

  def model_of_controller
    ::ForemanOpenscap::ArfReport
  end

  def index
    @arf_reports = resource_base.includes(:policy, :openscap_proxy, :host => %i[policies last_report_object host_statuses])
                                .search_for(params[:search], :order => params[:order])
                                .paginate(:page => params[:page], :per_page => params[:per_page])
  end

  def show
  end

  def show_html
  end

  def parse_html
    begin
      self.response_body = @arf_report.to_html
    rescue => e
      render :text => _(e.message)
    end
  end

  def parse_bzip
    begin
      response = @arf_report.to_bzip
      send_data response, :filename => "#{format_filename}.xml.bz2", :type => 'application/octet-stream', :disposition => 'attachement'
    rescue => e
      process_error(:error_msg => (_("Failed to downloaded ARF report as bzip: %s") % e.message),
                    :error_redirect => arf_report_path(@arf_report.id))
    end
  end

  def download_html
    begin
      response = @arf_report.to_html
      send_data response, :filename => "#{format_filename}.html",
                          :type => 'text/html', :disposition => 'attachement'
    rescue => e
      process_error(:error_msg => _("Failed to downloaded ARF report in HTML: %s") % e.message,
                    :error_redirect => arf_report_path(@arf_report.id))
    end
  end

  def destroy
    if @arf_report.destroy
      process_success(:success_msg => _("Successfully deleted ARF report."), :success_redirect => arf_reports_path)
    else
      process_error(:error_msg => _("Failed to delete ARF Report for host %{host_name} reported at %{reported_at}") % { :host_name => @arf_report.host.name, :reported_at => @arf_report.reported_at })
    end
  end

  def delete_multiple
  end

  def submit_delete_multiple
    failed_deletes = @arf_reports.reject(&:destroy).count
    if failed_deletes > 0
      process_error(:error_msg => (_("Failed to delete %s compliance reports") % failed_deletes),
                    :error_redirect => arf_reports_path)
    else
      process_success(:success_msg => (_("Successfully deleted %s compliance reports") % @arf_reports.size),
                      :success_redirect => arf_reports_path)
    end
  end

  private

  def find_arf_report
    @arf_report = resource_base.includes(:logs => %i[message source]).find(params[:id])
  end

  def find_multiple
    if params[:arf_report_ids].present?
      @arf_reports = ::ForemanOpenscap::ArfReport.where(:id => params[:arf_report_ids])
      if @arf_reports.empty?
        error _('No compliance reports were found.')
        redirect_to(arf_reports_path) && (return false)
      end
    else
      error _('No compliance reports selected')
      redirect_to(arf_reports_path) && (return false)
    end
    return @arf_reports
  rescue => e
    error _("Something went wrong while selecting compliance reports - %s") % e
    logger.debug e.message
    logger.debug e.backtrace.join("\n")
    redirect_to(arf_reports_path) && (return false)
  end

  def action_permission
    case params[:action]
    when 'show_html', 'parse_html', 'parse_bzip', 'download_html'
      :view
    when 'delete_multiple', 'submit_delete_multiple'
      :destroy
    else
      super
    end
  end
end
