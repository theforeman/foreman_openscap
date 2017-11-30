class AddSizeToScapContent < ActiveRecord::Migration[4.2]
  def change
    change_column :foreman_openscap_scap_contents, :scap_file, :binary, :limit => 16.megabyte
  end
end
