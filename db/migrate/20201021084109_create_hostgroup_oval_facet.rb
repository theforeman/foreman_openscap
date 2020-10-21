class CreateHostgroupOvalFacet < ActiveRecord::Migration[6.0]
  def change
    create_table :foreman_openscap_hostgroup_oval_facets do |t|
      t.references 'hostgroup', :null => false
    end

    add_index :foreman_openscap_hostgroup_oval_facets, [:hostgroup_id], :unique => true, :name => :foreman_openscap_hostgroup_oval_facets_hostgroup_id

    create_table :foreman_openscap_hostgroup_oval_facet_oval_policies do |t|
      t.references 'oval_policy', :null => false, :index => { :name => 'index_hg_oval_facet_oval_policies_on_oval_policy_id'}
      t.references 'oval_facet', :null => false, :index => { :name => 'index_hg_oval_facet_oval_policies_on_hg_oval_facet_id'}
    end
  end
end
