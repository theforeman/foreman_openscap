class AddScapFileToScapContent < ActiveRecord::Migration[4.2]
  def change
    add_column :scaptimony_scap_contents, :scap_file, :binary
  end
end
