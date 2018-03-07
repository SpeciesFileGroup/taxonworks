class AddIsAbsentToAssertedDistribution < ActiveRecord::Migration[4.2]
  def change
    add_column :asserted_distributions, :is_absent, :boolean
  end
end
