class AddSizeToScapContent < ActiveRecord::Migration
  def change
    change_column :foreman_openscap_scap_contents, :scap_file, :binary, :limit => 16.megabyte
  end
end
