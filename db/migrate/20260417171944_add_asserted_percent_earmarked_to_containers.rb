class AddAssertedPercentEarmarkedToContainers < ActiveRecord::Migration[8.1]
  def change
    add_column :containers, :asserted_percent_earmarked, :decimal
  end
end
