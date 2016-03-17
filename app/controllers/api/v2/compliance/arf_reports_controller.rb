#
# Copyright (c) 2014--2015 Red Hat Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 3 (GPLv3). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv3
# along with this software; if not, see http://www.gnu.org/licenses/gpl.txt
#

require 'foreman_openscap/helper'

module Api
  module V2
    module Compliance

      class ArfReportsController < V2::BaseController
        include Api::Version2
        include Foreman::Controller::SmartProxyAuth

        add_smart_proxy_filters :create, :features => 'Openscap'

        before_filter :find_resource, :only => %w(show destroy)

        def resource_name
          '::ForemanOpenscap::ArfReport'
        end

        def get_resource
          instance_variable_get :"@arf_report" or fail 'no resource loaded'
        end

        resource_description do
          resource_id 'foreman_openscap_arf_reports'
          api_version 'v2'
          api_base_url "/api/v2"
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

        api :DELETE, '/compliance/arf_reports/:id', N_('Deletes an ARF Report')
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

        private

        def find_resource
          not_found and return if params[:id].blank?
          instance_variable_set("@arf_report", resource_scope.find(params[:id]))
        end
      end
    end
  end
end
