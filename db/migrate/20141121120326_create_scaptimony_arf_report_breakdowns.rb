class CreateScaptimonyArfReportBreakdowns < ActiveRecord::Migration
  def self.up
    execute <<-SQL
CREATE VIEW scaptimony_arf_report_breakdowns AS
  SELECT
    arf.id as arf_report_id,
    COUNT(CASE WHEN result.name IN ('pass','fixed') THEN 1 ELSE null END) as passed,
    COUNT(CASE result.name WHEN 'fail' THEN 1 ELSE null END) as failed,
    COUNT(CASE WHEN result.name NOT IN ('pass', 'fixed', 'fail', 'notselected', 'notapplicable') THEN 1 ELSE null END) as othered
  FROM
    scaptimony_arf_reports arf,
    scaptimony_xccdf_rule_results rule,
    scaptimony_xccdf_results result
  WHERE
    arf.id = rule.arf_report_id
    AND rule.xccdf_result_id = result.id
  GROUP BY arf.id;
    SQL
  end

  def self.down
    execute 'DROP VIEW scaptimony_arf_report_breakdowns' if table_exists? 'scaptimony_arf_report_breakdowns'
  end
end
