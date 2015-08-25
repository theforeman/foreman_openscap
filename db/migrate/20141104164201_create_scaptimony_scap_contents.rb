class CreateScaptimonyScapContents < ActiveRecord::Migration
  def change
    create_table :scaptimony_scap_contents do |t|
      t.timestamps
    end
  end
end
