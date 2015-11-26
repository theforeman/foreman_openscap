class AddOpenscapProxyToHostAndHostgroup < ActiveRecord::Migration
  def up
    add_column :hostgroups, :openscap_proxy_id, :integer
    add_column :hosts, :openscap_proxy_id, :integer
    add_column :reports, :openscap_proxy_id, :integer

    #to ensure backward compatiblity
    #this relies on the fact that only one scap proxy was registered
    #because there has not been support for multiple scap proxies
    reports = ForemanOpenscap::ArfReport.where(:openscap_proxy_id => nil)
    scap_proxy = SmartProxy.with_features("Openscap").first
    unless scap_proxy.nil?
      reports.each do |report|
        report.openscap_proxy = scap_proxy
        report.save!
      end
    end
  end

  def down
    remove_column :hostgroups, :openscap_proxy_id, :integer
    remove_column :hosts, :openscap_proxy_id, :integer
    remove_column :reports, :openscap_proxy_id
  end
end
