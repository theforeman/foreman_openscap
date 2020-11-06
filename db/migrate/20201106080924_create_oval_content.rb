class CreateOvalContent < ActiveRecord::Migration[6.0]
  def change
    create_table :foreman_openscap_oval_contents do |t|
      t.string :name, null: false
      t.string :digest
      t.string :original_filename
      t.binary :scap_file
    end

    add_index :foreman_openscap_oval_contents, :name, :unique => true
  end
end
