class AddAssertedDistributionShapeNotNullConstraints < ActiveRecord::Migration[7.2]
  def change
    change_column_null :asserted_distributions, :asserted_distribution_shape_type, false
    change_column_null :asserted_distributions, :asserted_distribution_shape_id, false
  end
end
