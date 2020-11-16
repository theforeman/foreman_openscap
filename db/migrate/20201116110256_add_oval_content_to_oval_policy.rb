class AddOvalContentToOvalPolicy < ActiveRecord::Migration[6.0]
  def change
    add_column :foreman_openscap_oval_policies, :oval_content_id, :integer, :references => :oval_content
  end
end
