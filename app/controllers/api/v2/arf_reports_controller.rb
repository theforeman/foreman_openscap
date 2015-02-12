module Api
  module V2
    class ArfReportsController < ::Api::V2::BaseController
      before_filter :find_resource, :only => %w{show destroy}
      def resource_name
        'Scaptimony::ArfReport'
      end

      def get_resource
        instance_variable_get :"@arf_report" or raise 'no resource loaded'
      end

      resource_description do
        resource_id 'scaptimony_arf_reports'
        api_version 'v2'
        api_base_url "/api/v2"
      end

      api :GET, '/arf_reports', N_('List Arf reports')
      param_group :search_and_pagination, ::Api::V2::BaseController

      def index
        @arf_reports = resource_scope_for_index(:permission => :edit_compliance).includes(:arf_report_breakdown, :asset)
      end

      api :GET, '/arf_reports/:id', N_('Show an Arf report')
      param :id, :identifier, :required => true

      def show
      end

      api :DELETE, '/arf_reports/:id', N_('Deletes an Arf Report')
      param :id, :identifier, :required => true

      def destroy
        process_response @arf_report.destroy
      end

      private
      def find_resource
        not_found and return if params[:id].blank?
        instance_variable_set("@arf_report", resource_scope.find(params[:id]))
      end
    end
  end
end