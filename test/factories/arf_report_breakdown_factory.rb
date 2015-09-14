FactoryGirl.define do
  factory :arf_report_breakdown, :class => 'ForemanOpenscap::ArfReportBreakdown' do
    passed 0
    failed 0
    othered 0
  end
end
