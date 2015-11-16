class ArfReportsController < ApplicationController
  include Foreman::Controller::AutoCompleteSearch

  before_filter :find_by_id, :only => [:show, :show_html, :destroy, :parse_html, :parse_bzip]

  def model_of_controller
    ::ForemanOpenscap::ArfReport
  end

  def index
    @arf_reports = resource_base.includes(:asset)
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
      send_data response, :filename => "#{@arf_report.id}_arf_report.bz2", :type => 'application/octet-stream', :disposition => 'attachement'
    rescue => e
      process_error(:error_msg => (_("Failed to downloaded Arf report as bzip: #{e.message}")),
                    :error_redirect => arf_report_path(@arf_report.id))
    end
  end

  def destroy
    if @arf_report.destroy
      process_success(:success_msg => (_("Successfully deleted Arf report.")), :success_redirect => arf_reports_path)
    else
      process_error(:error_msg => _("Failed to delete Arf Report for host #{@arf_report.host.name} reported at #{@arf_report.reported_at}"))
    end
  end

  private

  def find_by_id
    @arf_report = resource_base.find(params[:id])
  end

  def action_permission
    case params[:action]
    when 'show_html', 'parse_html', 'parse_bzip'
      :view
    else
      super
    end
  end
end
