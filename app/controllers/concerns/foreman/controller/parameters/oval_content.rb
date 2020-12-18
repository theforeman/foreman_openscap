module Foreman::Controller::Parameters::OvalContent
  extend ActiveSupport::Concern

  class_methods do
    def oval_content_params_filter
      Foreman::ParameterFilter.new(::ForemanOpenscap::OvalContent).tap do |filter|
        filter.permit :original_filename, :scap_file, :name, :url, :location_ids => [], :organization_ids => []
      end
    end
  end

  def oval_content_params
    read_file_content self.class.oval_content_params_filter.filter_params(params, parameter_filter_context)
  end

  def read_file_content(params)
    return params unless file = params[:scap_file]
    content = file.read
    filename = file.original_filename
    params.merge(:scap_file => content, :original_filename => params[:original_filename] || filename)
  end
end
