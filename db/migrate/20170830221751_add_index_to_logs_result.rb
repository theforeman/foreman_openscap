class AddIndexToLogsResult < ActiveRecord::Migration
  def up
    add_index :logs, :result
  end

  def down
    remove_index :logs, :result
  end
end
