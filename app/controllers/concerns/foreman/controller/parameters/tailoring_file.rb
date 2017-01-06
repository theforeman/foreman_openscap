module Foreman::Controller::Parameters::TailoringFile
  extend ActiveSupport::Concern

  class_methods do
    def tailoring_file_params_filter
      Foreman::ParameterFilter.new(::ForemanOpenscap::TailoringFile).tap do |filter|
        filter.permit :name, :scap_file, :original_filename, :location_ids => [], :organization_ids => []
      end
    end
  end

  def tailoring_file_params
    self.class.tailoring_file_params_filter.filter_params(params, parameter_filter_context)
  end
end
