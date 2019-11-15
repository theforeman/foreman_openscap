module ForemanOpenscap
  module Api::V2::ScapApiControllerExtensions
    extend ActiveSupport::Concern

    def resource_class_for(resource)
      super "foreman_openscap/#{resource}"
    end
  end
end
