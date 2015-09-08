class MigrateFromScaptimony < ActiveRecord::Migration
  def up
    ActiveRecord::Base.connection.tables.grep(/^scaptimony/).each do |table|
      rename_table table, table.sub(/^scaptimony/, "foreman_openscap")
    end

    execute 'DROP VIEW scaptimony_arf_report_breakdowns' if table_exists? 'scaptimony_arf_report_breakdowns'
    execute 'DROP VIEW foreman_openscap_arf_report_breakdowns' if table_exists? 'foreman_openscap_arf_report_breakdowns'

    execute <<-SQL
      CREATE VIEW foreman_openscap_arf_report_breakdowns AS
        SELECT
          arf.id as arf_report_id,
          COUNT(CASE WHEN result.name IN ('pass','fixed') THEN 1 ELSE null END) as passed,
          COUNT(CASE result.name WHEN 'fail' THEN 1 ELSE null END) as failed,
          COUNT(CASE WHEN result.name NOT IN ('pass', 'fixed', 'fail', 'notselected', 'notapplicable') THEN 1 ELSE null END) as othered
        FROM
          foreman_openscap_arf_reports arf
        LEFT OUTER JOIN
          foreman_openscap_xccdf_rule_results rule
          ON arf.id = rule.arf_report_id
        LEFT OUTER JOIN foreman_openscap_xccdf_results result
          ON rule.xccdf_result_id = result.id
        GROUP BY arf.id;
          SQL

    taxonomies = TaxableTaxonomy.where(:taxable_type => ["Scaptimony::ArfReport", "Scaptimony::Policy", "Scaptimony::ScapContent"])
    taxonomies.each { |t| t.taxable_type = t.taxable_type.sub(/^Scaptimony/, "ForemanOpenscap")}.map(&:save!)
  end

  def down
    ActiveRecord::Base.connection.tables.grep(/^foreman_openscap/).each do |table|
      rename_table table, table.sub(/^foreman_openscap/, "scaptimony")
    end

    execute 'DROP VIEW scaptimony_arf_report_breakdowns' if table_exists? 'scaptimony_arf_report_breakdowns'
    execute 'DROP VIEW foreman_openscap_arf_report_breakdowns' if table_exists? 'foreman_openscap_arf_report_breakdowns'

    execute <<-SQL
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

    taxonomies = TaxableTaxonomy.where(:taxable_type => ["ForemanOpenscap::ArfReport", "ForemanOpenscap::Policy", "ForemanOpenscap::ScapContent"])
    taxonomies.each { |t| t.taxable_type = t.taxable_type.sub(/^ForemanOpenscap/, "Scaptimony")}.map(&:save!)
  end
end
