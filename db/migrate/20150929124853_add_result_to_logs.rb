class AddResultToLogs < ActiveRecord::Migration[4.2]
  def up
    add_column :logs, :result, :string
  end

  def down
    remove_column :logs, :result
  end
end
