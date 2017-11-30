class CreateScaptimonyScapContentProfiles < ActiveRecord::Migration[4.2]
  def change
    create_table :scaptimony_scap_content_profiles do |t|
      t.references :scap_content, :index => true
      t.string :profile_id
      t.string :title
    end
    add_index :scaptimony_scap_content_profiles, %i[scap_content_id profile_id],
              :unique => true, :name => :index_scaptimony_scap_content_profiles_scipi
  end
end
