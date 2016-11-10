class CreateTailoringFiles < ActiveRecord::Migration
  def up
    create_table :foreman_openscap_tailoring_files do |t|
      t.string :name, :unique => true, :null => false
      t.text :scap_file
      t.string :original_filename
      t.datetime :created_at
      t.datetime :updated_at
      t.string :digest, :null => false
    end

    add_column :foreman_openscap_policies, :tailoring_file_id, :integer, :references => :tailoring_file
    add_column :foreman_openscap_policies, :tailoring_file_profile_id, :integer, :references => :scap_content_profile
    add_column :foreman_openscap_scap_content_profiles, :tailoring_file_id, :integer, :references => :tailoring_file
  end

  def down
    remove_column :foreman_openscap_policies, :tailoring_file_id
    remove_column :foreman_openscap_policies, :tailoring_file_profile_id
    remove_column :foreman_openscap_scap_content_profiles, :tailoring_file_id
    drop_table :foreman_openscap_tailoring_files
  end
end
