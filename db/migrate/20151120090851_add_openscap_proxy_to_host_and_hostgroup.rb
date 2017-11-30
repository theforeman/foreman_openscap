class AddOpenscapProxyToHostAndHostgroup < ActiveRecord::Migration[4.2]
  def up
    add_column :hostgroups, :openscap_proxy_id, :integer
    add_column :hosts, :openscap_proxy_id, :integer
    add_column :reports, :openscap_proxy_id, :integer
  end

  def down
    remove_column :hostgroups, :openscap_proxy_id, :integer
    remove_column :hosts, :openscap_proxy_id, :integer
    remove_column :reports, :openscap_proxy_id
  end
end
