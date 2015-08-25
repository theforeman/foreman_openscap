class AddColumnsToScaptimonyScapContents < ActiveRecord::Migration
  def change
    add_column :scaptimony_scap_contents, :title, :string
    add_column :scaptimony_scap_contents, :original_filename, :string
    add_index :scaptimony_scap_contents, :title
    add_index :scaptimony_scap_contents, :original_filename
  end
end
