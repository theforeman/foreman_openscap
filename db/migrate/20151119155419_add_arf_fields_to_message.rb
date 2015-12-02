class AddArfFieldsToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :description, :text
    add_column :messages, :rationale, :text
    add_column :messages, :scap_references, :text
    add_column :messages, :severity, :string
  end
end
