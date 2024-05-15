class AddURLToOvalContent < ActiveRecord::Migration[6.0]
  def change
    add_column :foreman_openscap_oval_contents, :url, :string
  end
end
