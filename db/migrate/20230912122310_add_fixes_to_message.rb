class AddFixesToMessage < ActiveRecord::Migration[6.1]
  def change
    add_column :messages, :fixes, :text
  end
end
