module Foreman::Controller::Parameters::OvalPolicy
  extend ActiveSupport::Concern

  class_methods do
    def filter_params_list
      [:description, :name, :period,
       :weekday, :day_of_month, :cron_line,
       :oval_content_id,
       :location_ids => [], :organization_ids => []]
    end

    def oval_policy_params_filter
      Foreman::ParameterFilter.new(::ForemanOpenscap::OvalPolicy).tap do |filter|
        filter.permit filter_params_list
      end
    end
  end

  def oval_policy_params
    self.class.oval_policy_params_filter.filter_params(params, parameter_filter_context)
  end
end
