class AddDayOfMonthAndCronLineToScaptimonyPolicy < ActiveRecord::Migration[4.2]
  def change
    add_column :scaptimony_policies, :day_of_month, :integer
    add_column :scaptimony_policies, :cron_line, :string
  end
end
