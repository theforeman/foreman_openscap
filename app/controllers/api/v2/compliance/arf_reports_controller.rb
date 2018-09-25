require 'foreman_openscap/helper'

module Api
  module V2
    module Compliance
      class ArfReportsController < V2::BaseController
        include Api::Version2
        include Foreman::Controller::SmartProxyAuth
        include ForemanOpenscap::ArfReportsControllerCommonExtensions

        add_smart_proxy_filters :create, :features => 'Openscap'

        before_action :find_resource, :only => %w[show destroy download download_html]
        before_action :find_resources_before_create, :only => %w[create]
        skip_after_action :log_response_body, :only => %w[download download_html]

        def resource_name(resource = '::ForemanOpenscap::ArfReport')
          super resource
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
          arf_report = ForemanOpenscap::ArfReport.create_arf(@asset, @smart_proxy, params.to_unsafe_h)
          @asset.host.refresh_statuses([HostStatus.find_status_by_humanized_name("compliance")])
          render :json => { :result => :OK, :id => arf_report.id.to_s }
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

        def find_resources_before_create
          @asset = ForemanOpenscap::Helper::get_asset(params[:cname], params[:policy_id])

          if !params[:openscap_proxy_url] && !params[:openscap_proxy_name] && !@asset.host.openscap_proxy
            msg = _('Failed to upload Arf Report, OpenSCAP proxy name or url not found in params when uploading for %s and host is missing openscap_proxy') % @asset.host.name
            no_proxy_for_host(msg)
            return
          elsif !params[:openscap_proxy_url] && !params[:openscap_proxy_name] && @asset.host.openscap_proxy
            logger.debug 'No proxy params found when uploading arf report, falling back to asset.host.openscap_proxy'
            @smart_proxy = @asset.host.openscap_proxy
          else
            @smart_proxy = SmartProxy.unscoped.find_by :name => params[:openscap_proxy_name]
            @smart_proxy ||= SmartProxy.unscoped.find_by :url => params[:openscap_proxy_url]
          end

          unless @smart_proxy
            msg = _('No proxy found for %{name} or %{url}') % { :name => params[:openscap_proxy_name], :url => params[:openscap_proxy_url] }
            no_proxy_for_host(msg)
            return
          end
        end

        def handle_download_error(error)
          render_error 'standard_error', :status => :internal_error, :locals => { :exception => error }
        end

        def no_proxy_for_host(msg)
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
