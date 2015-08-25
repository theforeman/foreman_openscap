module ForemanOpenscap
  class ArfReportBreakdown < ActiveRecord::Base
    # This class aggregates counts of xccdf:rule-result by xccdf:result. The columns
    # (failed, passed, othered) mimics the 'Rule result breakdown' from OpenSCAP HTML
    # Report.
    #
    # Frameworks like scoped_search cannot do group-by, so this is implemented
    # as a database view.

    set_primary_key :arf_report_id

    protected
    def readonly?; true end
  end
end
