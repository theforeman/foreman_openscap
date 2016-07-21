require 'net/http'
require 'rest_client'
require 'json'
require 'tempfile'

module ForemanOpenscap
  class DataMigration
    def initialize(proxy_id)
      @proxy = ::SmartProxy.find(proxy_id)
      puts "Found proxy #{@proxy.to_label}"
      @url = @proxy.url
    end

    def available?
      return false unless @proxy && @url
      ::ProxyAPI::AvailableProxy.new(:url => @url).available? && foreman_available?
    end

    def migrate
      ForemanOpenscap::Asset.where(:assetable_type => "Host::Base").select { |a| a.host.nil? }.map(&:destroy)
      ForemanOpenscap::Asset.where(:assetable_type => "Hostgroup").select { |a| a.hostgroup.nil? }.map(&:destroy)

      old_arf_reports = ActiveRecord::Migration.execute("SELECT * FROM foreman_openscap_arf_reports;")
      old_arf_reports.select do |report|
        policy_id = report["policy_id"]
        date = DateTime.strptime(report["created_at"], "%Y-%m-%d %H:%M:%S")
        date += 1.second until arfs_by_reported(date).empty?

        host_name = fetch_host_name(report["asset_id"])
        arf_file = fetch_xml_file(report["id"])

        next if arf_file.blank?
        migrator = ::ProxyAPI::Migration.new(:url => @url)

        migrated_id = migrator.migrate_arf_report(arf_file, host_name, policy_id, date.to_i)

        migrated_arf = ForemanOpenscap::ArfReport.find(migrated_id["arf_id"])
        migrated_arf.update_attribute(:openscap_proxy_id, @proxy.id)
        puts "Migrated Old arf_report #{report['id']} as arf: #{migrated_arf.id}"
        delete_old_records(report["id"]) if migrated_arf
      end
    end

    private

    def foreman_available?
      foreman_status_url = Setting[:foreman_url] + '/status'
      response = JSON.parse(RestClient.get foreman_status_url)
      return true if response["status"] == "ok"
    rescue *::ProxyAPI::AvailableProxy::HTTP_ERRORS
      return false
    end

    def fetch_xml_file(id)
      query = ActiveRecord::Migration.execute("SELECT bzip_data FROM foreman_openscap_arf_report_raws WHERE arf_report_id=#{id} LIMIT 1;")
      ActiveRecord::Base.connection.unescape_bytea(query.first['bzip_data'])
    end

    def delete_old_records(id)
      ActiveRecord::Migration.execute("DELETE FROM foreman_openscap_arf_report_raws WHERE arf_report_id=#{id};")
      ActiveRecord::Migration.execute("DELETE FROM foreman_openscap_arf_reports WHERE id=#{id};")
      drop_empty_tables
    end

    def fetch_host_name(asset_id)
      asset = ForemanOpenscap::Asset.find(asset_id)
      ForemanOpenscap::Helper.find_name_or_uuid_by_host(asset.host)
    end

    def arfs_by_reported(time)
      ForemanOpenscap::ArfReport.where(:reported_at => time)
    end

    def drop_empty_tables
      old_arfs = ActiveRecord::Migration.execute("SELECT * FROM foreman_openscap_arf_reports;")
      ActiveRecord::Migration.drop_table(:foreman_openscap_arf_reports) unless old_arfs.any?
      old_raws = ActiveRecord::Migration.execute("SELECT * FROM foreman_openscap_arf_report_raws;")
      ActiveRecord::Migration.drop_table(:foreman_openscap_arf_report_raws) unless old_raws.any?
    end
  end
end

