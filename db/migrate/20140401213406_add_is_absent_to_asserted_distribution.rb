class AddIsAbsentToAssertedDistribution < ActiveRecord::Migration
  def change
    add_column :asserted_distributions, :is_absent, :boolean
  end
end
