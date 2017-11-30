class AddColumnsToScaptimonyScapContents < ActiveRecord::Migration[4.2]
  def change
    add_column :scaptimony_scap_contents, :title, :string
    add_column :scaptimony_scap_contents, :original_filename, :string
    add_index :scaptimony_scap_contents, :title
    add_index :scaptimony_scap_contents, :original_filename
  end
end
