class CreateScaptimonyScapContents < ActiveRecord::Migration
  def change
    create_table :scaptimony_scap_contents, &:timestamps
  end
end
