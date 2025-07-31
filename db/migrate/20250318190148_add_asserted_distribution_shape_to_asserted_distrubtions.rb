class AddAssertedDistributionShapeToAssertedDistrubtions < ActiveRecord::Migration[7.2]
  def change
    add_column :asserted_distributions, :asserted_distribution_shape_id, :integer
    add_column :asserted_distributions, :asserted_distribution_shape_type, :string

    add_index :asserted_distributions,
      [:asserted_distribution_shape_id, :asserted_distribution_shape_type],
      name: 'asserted_distribution_polymorphic_shape_index'
  end
end
