class AddDateTimeMadeToObservation < ActiveRecord::Migration[6.1]
  def change
    add_column :observations, :year_made, :integer, size: 4
    add_column :observations, :month_made, :integer, size: 2
    add_column :observations, :day_made, :integer, size: 2

    add_column :observations, :time_made, :time
  end
end
