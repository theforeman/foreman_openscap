class AddResultToLogs < ActiveRecord::Migration
  def up
    add_column :logs, :result, :string
  end

  def down
    remove_column :logs, :result
  end
end
