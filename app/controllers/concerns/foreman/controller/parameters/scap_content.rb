module Foreman::Controller::Parameters::ScapContent
  extend ActiveSupport::Concern

  class_methods do
    def scap_content_params_filter
      Foreman::ParameterFilter.new(::ForemanOpenscap::ScapContent).tap do |filter|
        filter.permit :original_filename, :scap_file, :title, :location_ids => [], :organization_ids => []
      end
    end
  end

  def scap_content_params
    self.class.scap_content_params_filter.filter_params(params, parameter_filter_context)
  end
end
