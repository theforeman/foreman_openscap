module Foreman::Controller::Parameters::OvalContent
  extend ActiveSupport::Concern

  class_methods do
    def oval_content_params_filter
      Foreman::ParameterFilter.new(::ForemanOpenscap::OvalContent).tap do |filter|
        filter.permit :original_filename, :scap_file, :name, :location_ids => [], :organization_ids => []
      end
    end
  end

  def oval_content_params
    self.class.oval_content_params_filter.filter_params(params, parameter_filter_context)
  end
end
