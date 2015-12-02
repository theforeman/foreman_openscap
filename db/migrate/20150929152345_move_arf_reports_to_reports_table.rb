class MoveArfReportsToReportsTable < ActiveRecord::Migration

  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def up
    old_arf_reports = execute("SELECT * FROM foreman_openscap_arf_reports;")

    #select only reports with existing host
    old_arf_reports = old_arf_reports.select do |item|
      asset = ForemanOpenscap::Asset.find item['asset_id']
      !asset.host.nil? && asset.assetable_type = "Host::Base"
    end
    #and remove assets without assetable
    ForemanOpenscap::Asset.where(:assetable_type => "Host::Base").select { |a| a.host.nil? }.map(&:destroy)
    ForemanOpenscap::Asset.where(:assetable_type => "Hostgroup").select { |a| a.hostgroup.nil? }.map(&:destroy)

    old_arf_reports.each do |item|
      metrics = breakdown_to_metrics item["id"]

      #reported_at attribute must be unique
      reported_at = DateTime.strptime(item["created_at"], "%Y-%m-%d %H:%M:%S")

      reported_at += 1.second until arfs_by_reported(reported_at).empty?

      arf = ForemanOpenscap::ArfReport.create!(:metrics => metrics,
                                               :reported_at => reported_at,
                                               :created_at => item["created_at"],
                                               :updated_at => item["updated_at"],
                                               :host_id => item["asset_id"],
                                               :status => metrics)

      ForemanOpenscap::PolicyArfReport.create!(:arf_report_id => arf.id, :policy_id => item["policy_id"], :digest => item["digest"])

      xccdf_rules.each { |rule_item| Source.find_or_create(rule_item["xid"]) }

      xccdf_rule_results(item["id"]).each do |rr_item|
        message = Message.find_or_create("No message for this log")

        rule_item = xccdf_rule(rr_item['xccdf_rule_id'])
        source = Source.find_or_create(rule_item['xid'])

        Log.create!(:report_id => arf.id,
                    :result => xccdf_result(rr_item["xccdf_result_id"])['name'],
                    :message_id => message.id,
                    :source_id => source.id,
                    :level => :info)
      end
    end

    execute 'DROP VIEW foreman_openscap_arf_report_breakdowns' if table_exists? 'foreman_openscap_arf_report_breakdowns'
    drop_table :foreman_openscap_xccdf_results
    drop_table :foreman_openscap_xccdf_rules
    drop_table :foreman_openscap_xccdf_rule_results
    drop_table :foreman_openscap_arf_reports
    drop_table :foreman_openscap_arf_report_raws
  end

  def down
    #warning! we cannot fully revert since arf_report_raws got dropped and we have no way of recreating them
    create_table :foreman_openscap_arf_reports do |t|
      t.references :asset, :index => true
      t.references :policy, :index => true
      t.datetime :date
      t.string :digest, :limit => 128

      t.timestamps
    end
    add_index :foreman_openscap_arf_reports, :digest, :unique => true

    add_index :foreman_openscap_arf_reports, [:asset_id, :policy_id, :date, :digest],
              :unique => true, :name => :index_openscap_arf_reports_unique_set

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

  private

  def breakdown_to_metrics(report_id)
    execute("SELECT passed, failed, othered FROM foreman_openscap_arf_report_breakdowns WHERE arf_report_id='#{report_id}';").first
  end

  def xccdf_rule_results(report_id)
    execute("SELECT arf_report_id, xccdf_result_id, xccdf_rule_id
             FROM foreman_openscap_xccdf_rule_results
             WHERE arf_report_id='#{report_id}';")
  end

  def xccdf_rules
    execute("SELECT xid FROM foreman_openscap_xccdf_rules;")
  end

  def xccdf_rule(rule_id)
    execute("SELECT xid
             FROM foreman_openscap_xccdf_rules
             WHERE foreman_openscap_xccdf_rules.id = '#{rule_id}';").first
  end

  def xccdf_result(result_id)
    execute("SELECT name FROM foreman_openscap_xccdf_results WHERE id = '#{result_id}';").first
  end

  def arfs_by_reported(time)
    ForemanOpenscap::ArfReport.where(:reported_at => time)
  end

  def report(arf)
    execute("SELECT id
             FROM foreman_openscap_arf_reports
             WHERE date = '#{arf.reported_at}' AND
                   digest = '#{arf.policy_arf_report.digest}';").first
  end
end
