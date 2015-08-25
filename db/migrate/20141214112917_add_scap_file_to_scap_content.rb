class AddScapFileToScapContent < ActiveRecord::Migration
  def change
    add_column :scaptimony_scap_contents, :scap_file, :binary
  end
end
