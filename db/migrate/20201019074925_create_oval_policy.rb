class CreateOvalPolicy < ActiveRecord::Migration[6.0]
  def change
    create_table :foreman_openscap_oval_policies do |t|
      t.string :name
      t.string :description
      t.string :period
      t.string :weekday
      t.integer :day_of_month
      t.string :cron_line
      t.timestamps
    end
  end
end
