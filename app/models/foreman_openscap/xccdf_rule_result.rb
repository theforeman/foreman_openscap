module ForemanOpenscap
  class XccdfRuleResult < ActiveRecord::Base

    belongs_to :arf_report
    belongs_to :xccdf_result
    belongs_to :xccdf_rule

    def self.f(result_name)
      includes(:xccdf_result).where("scaptimony_xccdf_results.name = '#{result_name}'")
    end
  end
end
