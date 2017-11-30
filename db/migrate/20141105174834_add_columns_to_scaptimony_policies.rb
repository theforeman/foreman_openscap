class AddColumnsToScaptimonyPolicies < ActiveRecord::Migration[4.2]
  def change
    add_column :scaptimony_policies, :xccdf_profile, :string
    add_column :scaptimony_policies, :period, :string
    add_column :scaptimony_policies, :weekday, :string
    add_column :scaptimony_policies, :description, :string

    # This works only with rails-4, I want to support rails-3 too
    # add_reference :scaptimony_policies, :scap_content, index: true
    add_column :scaptimony_policies, :scap_content_id, :integer, :references => :scap_content
  end
end
