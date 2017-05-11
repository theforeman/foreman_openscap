module ForemanOpenscap
  module LogExtensions
    extend ActiveSupport::Concern
    included do
      SCAP_RESULT = %w(pass fail error unknown notapplicable notchecked notselected informational fixed).freeze
      validate :scap_result
    end

    private

    def scap_result
      if report.is_a? ForemanOpenscap::ArfReport
        errors.add(:result, _('is not included in SCAP_RESULT')) unless SCAP_RESULT.include? result
      end
    end
  end
end
