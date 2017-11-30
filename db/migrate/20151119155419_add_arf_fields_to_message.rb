class AddArfFieldsToMessage < ActiveRecord::Migration[4.2]
  def change
    add_column :messages, :description, :text
    add_column :messages, :rationale, :text
    add_column :messages, :scap_references, :text
    add_column :messages, :severity, :string
  end
end
