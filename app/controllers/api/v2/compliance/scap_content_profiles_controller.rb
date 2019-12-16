module Api::V2
  module Compliance
    class ScapContentProfilesController < ::Api::V2::BaseController
      include ForemanOpenscap::Api::V2::ScapApiControllerExtensions

      api :GET, '/compliance/scap_content_profiles', N_('List SCAP content profiles')
      param_group :search_and_pagination, ::Api::V2::BaseController
      add_scoped_search_description_for(::ForemanOpenscap::ScapContentProfile)

      def index
        @scap_content_profiles = resource_scope_for_index(:permission => :view_scap_contents).includes(:scap_content, :tailoring_file)
      end
    end
  end
end
