class MoveArfReportsToReportsTable < ActiveRecord::Migration[4.2]
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def up
    execute 'DROP VIEW foreman_openscap_arf_report_breakdowns' if table_exists? 'foreman_openscap_arf_report_breakdowns'
    drop_table :foreman_openscap_xccdf_results
    drop_table :foreman_openscap_xccdf_rules
    drop_table :foreman_openscap_xccdf_rule_results
  end

  def down
    create_table :foreman_openscap_xccdf_results do |t|
      t.string :name, :limit => 16, :null => false
    end
    add_index :foreman_openscap_xccdf_results, [:name], :unique => true

    create_table :foreman_openscap_xccdf_rules do |t|
      t.string :xid, :null => false
    end
    add_index :foreman_openscap_xccdf_rules, [:xid], :unique => true

    create_table :foreman_openscap_xccdf_rule_results do |t|
      t.references :arf_report, :index => true, :null => false
      t.references :xccdf_result, :index => true, :null => false
      t.references :xccdf_rule, :index => true, :null => false
    end

    create_table :foreman_openscap_arf_report_raws, :id => false do |t|
      t.references :arf_report, :index => true, :null => false
      t.integer :size
      t.binary :raw
    end
    add_index :foreman_openscap_arf_report_raws, [:arf_report_id], :unique => true

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

    ForemanOpenscap::ArfReport::RESULT.each do |n|
      execute("INSERT INTO foreman_openscap_xccdf_results (name) VALUES ('#{n}');")
    end

    ForemanOpenscap::ArfReport.order('id').each do |arf|
      execute("INSERT INTO foreman_openscap_arf_reports (asset_id, policy_id, date, digest, created_at, updated_at)
                      VALUES ('#{arf.host_id}', '#{arf.policy.id}', '#{arf.reported_at}',
                             '#{arf.policy_arf_report.digest}', '#{arf.created_at}', '#{arf.updated_at}');")
      record = report(arf)
      arf.logs.each do |log|
        xccdf_result_item = execute("SELECT * FROM foreman_openscap_xccdf_results WHERE name = '#{log.result}';").first
        xccdf_rule_item = execute("SELECT * FROM foreman_openscap_xccdf_rules WHERE xid = '#{log.source.value}';").first
        unless xccdf_rule_item
          execute("INSERT INTO foreman_openscap_xccdf_rules (xid) VALUES ('#{log.source.value}');")
          xccdf_rule_item = execute("SELECT * FROM foreman_openscap_xccdf_rules WHERE xid = '#{log.source.value}';").first
        end
        execute("INSERT INTO foreman_openscap_xccdf_rule_results (arf_report_id, xccdf_result_id, xccdf_rule_id)
                        VALUES ('#{record['id']}', '#{xccdf_result_item['id']}', '#{xccdf_rule_item['id']}');")
        msg = log.message
        src = log.source
        log.destroy
        msg.destroy if msg.logs.empty?
        src.destroy if src.logs.empty?
      end
      # arf.destroy fires arf_report_raw.destroy
      execute("DELETE FROM reports WHERE id = '#{arf.id}';")
    end
    ForemanOpenscap::PolicyArfReport.all.map(&:destroy)
  end
end
