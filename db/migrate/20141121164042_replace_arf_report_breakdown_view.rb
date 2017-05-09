class ReplaceArfReportBreakdownView < ActiveRecord::Migration
  def self.up
    execute 'DROP VIEW IF EXISTS scaptimony_arf_report_breakdowns'
    execute <<-SQL.strip_heredoc
      CREATE VIEW scaptimony_arf_report_breakdowns AS
        SELECT
          arf.id as arf_report_id,
          COUNT(CASE WHEN result.name IN ('pass','fixed') THEN 1 ELSE null END) as passed,
          COUNT(CASE result.name WHEN 'fail' THEN 1 ELSE null END) as failed,
          COUNT(CASE WHEN result.name NOT IN ('pass', 'fixed', 'fail', 'notselected', 'notapplicable') THEN 1 ELSE null END) as othered
        FROM
          scaptimony_arf_reports arf
        LEFT OUTER JOIN
          scaptimony_xccdf_rule_results rule
          ON arf.id = rule.arf_report_id
        LEFT OUTER JOIN scaptimony_xccdf_results result
          ON rule.xccdf_result_id = result.id
        GROUP BY arf.id;
    SQL
  end

  def self.down
    execute 'DROP VIEW scaptimony_arf_report_breakdowns' if table_exists? 'scaptimony_arf_report_breakdowns'
  end
end
