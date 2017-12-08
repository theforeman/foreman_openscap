require 'foreman_openscap/helper'

module Api
  module V2
    module Compliance
      class ArfReportsController < V2::BaseController
        include Api::Version2
        include Foreman::Controller::SmartProxyAuth
        include ForemanOpenscap::ArfReportsControllerCommonExtensions

        add_smart_proxy_filters :create, :features => 'Openscap'

        before_filter :find_resource, :only => %w[show destroy download download_html]
        skip_after_filter :log_response_body, :only => %w[download download_html]

        def resource_name
          '::ForemanOpenscap::ArfReport'
        end

        def get_resource(message = 'no resource loaded')
          instance_variable_get(:"@arf_report") || raise(message)
        end

        api :GET, '/compliance/arf_reports', N_('List ARF reports')
        param_group :search_and_pagination, ::Api::V2::BaseController

        def index
          @arf_reports = resource_scope_for_index(:permission => :view_arf_reports).includes(:openscap_proxy, :policy, :host)
        end

        api :GET, '/compliance/arf_reports/:id', N_('Show an ARF report')
        param :id, :identifier, :required => true

        def show
        end

        api :DELETE, '/compliance/arf_reports/:id', N_('Delete an ARF Report')
        param :id, :identifier, :required => true

        def destroy
          process_response @arf_report.destroy
        end

        api :POST, "/compliance/arf/:cname/:policy_id/:date", N_("Upload an ARF report")
        param :cname, :identifier, :required => true
        param :policy_id, :identifier, :required => true
        param :date, :identifier, :required => true

        def create
          asset = ForemanOpenscap::Helper::get_asset(params[:cname], params[:policy_id])
          if asset.host.openscap_proxy
            arf_report = ForemanOpenscap::ArfReport.create_arf(asset, params)
            asset.host.refresh_statuses([HostStatus.find_status_by_humanized_name("compliance")])
            render :json => { :result => :OK, :id => arf_report.id.to_s }
          else
            no_proxy_for_host asset
          end
        end

        api :GET, "/compliance/arf_reports/:id/download/", N_("Download bzipped ARF report")
        param :id, :identifier, :required => true

        def download
          response = @arf_report.to_bzip
          send_data response, :filename => "#{format_filename}.xml.bz2"
        rescue => e
          handle_download_error e
        end

        api :GET, "/compliance/arf_reports/:id/download_html/", N_("Download ARF report in HTML")
        param :id, :identifier, :required => true

        def download_html
          response = @arf_report.to_html
          send_data response, :filename => "#{format_filename}.html"
        rescue => e
          handle_download_error e
        end

        private

        def find_resource
          not_found && return if params[:id].blank?
          instance_variable_set("@arf_report", resource_scope.find(params[:id]))
        end

        def handle_download_error(error)
          render_error 'standard_error', :status => :internal_error, :locals => { :exception => error }
        end

        def no_proxy_for_host(asset)
          msg = _('Failed to upload Arf Report, no OpenSCAP proxy set for host %s') % asset.host.name
          logger.error msg
          render :json => { :result => msg }, :status => :unprocessable_entity
        end

        def action_permission
          case params[:action]
          when 'download', 'download_html'
            :view
          else
            super
          end
        end
      end
    end
  end
end
