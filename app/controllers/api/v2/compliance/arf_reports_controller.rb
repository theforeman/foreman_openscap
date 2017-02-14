require 'foreman_openscap/helper'

module Api
  module V2
    module Compliance

      class ArfReportsController < V2::BaseController
        include Api::Version2
        include Foreman::Controller::SmartProxyAuth

        add_smart_proxy_filters :create, :features => 'Openscap'

        before_filter :find_resource, :only => %w(show destroy download)
        skip_after_filter :log_response_body, :only => %w(download)

        def resource_name
          '::ForemanOpenscap::ArfReport'
        end

        def get_resource(message = 'no resource loaded')
          instance_variable_get :"@arf_report" or fail message
        end

        api :GET, '/compliance/arf_reports', N_('List ARF reports')
        param_group :search_and_pagination, ::Api::V2::BaseController

        def index
          @arf_reports = resource_scope_for_index(:permission => :edit_compliance).includes(:asset)
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
          arf_report = ForemanOpenscap::ArfReport.create_arf(asset, params)
          asset.host.refresh_statuses if asset.host
          render :json => { :result => :OK, :id => arf_report.id.to_s }
        end

        api :GET, "/compliance/arf_reports/:id/download/", N_("Download bzipped ARF report")
        param :id, :identifier, :required => true

        def download
          response = @arf_report.to_bzip
          send_data response, :filename => "#{@arf_report.id}_arf_report.bz2"
        rescue => e
          render_error 'standard_error', :status => :internal_error, :locals => { :exception => e }
        end

        private

        def find_resource
          not_found and return if params[:id].blank?
          instance_variable_set("@arf_report", resource_scope.find(params[:id]))
        end

        def action_permission
          case params[:action]
          when 'download'
            :view
          else
            super
          end
        end
      end
    end
  end
end
