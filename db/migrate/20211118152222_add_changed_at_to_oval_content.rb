class AddChangedAtToOvalContent < ActiveRecord::Migration[6.0]
  def change
    add_column :foreman_openscap_oval_contents, :changed_at, :datetime
  end
end
