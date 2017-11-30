class CreateScaptimonyScapContents < ActiveRecord::Migration[4.2]
  def change
    create_table :scaptimony_scap_contents, &:timestamps
  end
end
