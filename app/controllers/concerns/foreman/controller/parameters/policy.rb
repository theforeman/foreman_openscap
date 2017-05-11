module Foreman::Controller::Parameters::Policy
  extend ActiveSupport::Concern
  include Foreman::Controller::Parameters::PolicyApi

  class_methods do
    def policy_params_filter
      Foreman::ParameterFilter.new(::ForemanOpenscap::Policy).tap do |filter|
        filter.permit(%i(current_step wizard_initiated) + filter_params_list)
      end
    end
  end
end
