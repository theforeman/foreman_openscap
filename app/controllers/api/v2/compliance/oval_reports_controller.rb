module Api
  module V2
    module Compliance
      class OvalReportsController < ::Api::V2::BaseController
        include Foreman::Controller::SmartProxyAuth
        add_smart_proxy_filters :create, :features => 'Openscap'

        skip_before_action :setup_has_many_params
        before_action :find_resources_before_create, :only => [:create]

        api :POST, "/compliance/oval_reports/:cname/:oval_policy_id/:date", N_("Upload an OVAL report - a list of CVEs for given host")
        param :cname, :identifier, :required => true
        param :oval_policy_id, :identifier, :required => true
        param :date, :identifier, :required => true

        def create
          ForemanOpenscap::Oval::Cves.new.create(@host, params.to_unsafe_h)
          if @host.errors.any?
            upload_fail host.errors.to_sentence
          else
            # @host.refresh_statuses([HostStatus.find_status_by_humanized_name("oval")])
            render :json => { :result => :ok }
          end
        end

        private

        def find_resources_before_create
          @host = ForemanOpenscap::Helper.find_host_by_name_or_uuid params[:cname]

          unless @host
            upload_fail(_('Could not find host identified by: %s') % params[:cname])
            return
          end
        end

        def upload_fail(msg)
          logger.error msg
          render :json => { :result => :fail, :errors => msg }, :status => :unprocessable_entity
        end

        def find_resource
        end
      end
    end
  end
end