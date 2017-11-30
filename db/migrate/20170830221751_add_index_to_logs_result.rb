class AddIndexToLogsResult < ActiveRecord::Migration[4.2]
  def up
    add_index :logs, :result
  end

  def down
    remove_index :logs, :result
  end
end
