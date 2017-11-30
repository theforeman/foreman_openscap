class AddConstraintToScaptimonyScapContents < ActiveRecord::Migration[4.2]
  def change
    change_column :scaptimony_scap_contents, :title, :string, :null => false
  end
end
