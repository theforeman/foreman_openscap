module ForemanOpenscap
  module Api::V2::HostsControllerExtensions
    extend ActiveSupport::Concern

    module Overrides
      def action_permission
        case params[:action]
        when 'policies_enc'
          'view'
        else
          super
        end
      end
    end

    included do
      prepend Overrides

      api :GET, "/hosts/:id/policies_enc", N_("Show config information for foreman_scap_client")
      param :id, :identifier_dottable, :required => true, :desc => N_("The identifier of the host")
      def policies_enc
        @encs = @host.policies_enc_raw.map { |hash| OpenStruct.new(hash) }
      end
    end
  end
end
