class AssertedDistributionPolymorphicObject < ActiveRecord::Migration[7.2]
  def change
    change_column_null :asserted_distributions, :otu_id, true

    add_column :asserted_distributions, :asserted_distribution_object_id, :integer
    add_column :asserted_distributions, :asserted_distribution_object_type, :string

    add_index :asserted_distributions,
      [:asserted_distribution_object_id, :asserted_distribution_object_type],
      name: 'asserted_distribution_polymorphic_object_index'

    ApplicationRecord.connection.execute(
      "UPDATE asserted_distributions SET asserted_distribution_object_type = 'Otu', asserted_distribution_object_id = otu_id;"
    )

    change_column_null :asserted_distributions, :asserted_distribution_object_type, false
    change_column_null :asserted_distributions, :asserted_distribution_object_id, false
  end
end
