module Foreman::Controller::Parameters::Policy
  extend ActiveSupport::Concern
  include PolicyApi

  class_methods do
    def policy_params_filter
      Foreman::ParameterFilter.new(::ForemanOpenscap::Policy).tap do |filter|
        filter.permit([:current_step, :wizard_initiated] + filter_params_list)
      end
    end
  end
end
