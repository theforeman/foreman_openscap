module Foreman::Controller::Parameters::Policy
  extend ActiveSupport::Concern

  class_methods do
    def policy_params_filter
      Foreman::ParameterFilter.new(::ForemanOpenscap::Policy).tap do |filter|
        filter.permit :description, :name, :period, :scap_content_id, :scap_content_profile_id,
                      :weekday, :day_of_month, :cron_line, :current_step, :location_ids => [], :organization_ids => [],
                      :hostgroup_ids => []
      end
    end
  end

  def policy_params
    self.class.policy_params_filter.filter_params(params, parameter_filter_context)
  end
end
