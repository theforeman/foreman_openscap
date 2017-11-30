class AddProfileToScaptimonyPolicies < ActiveRecord::Migration[4.2]
  def change
    # add_reference :scaptimony_policies, :scap_content_profile, index: true
    add_column :scaptimony_policies, :scap_content_profile_id, :integer, :references => :scap_content_profile
  end
end
