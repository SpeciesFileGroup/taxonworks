class AddAssertedPercentEmptyToContainers < ActiveRecord::Migration[8.1]
  def change
    add_column :containers, :asserted_percent_empty, :decimal
  end
end
