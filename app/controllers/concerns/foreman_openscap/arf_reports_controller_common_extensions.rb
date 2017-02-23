module ForemanOpenscap
  module ArfReportsControllerCommonExtensions
    extend ActiveSupport::Concern
    def format_filename
      "#{@arf_report.asset.name}-#{@arf_report.reported_at.to_formatted_s(:number)}"
    end
  end
end
