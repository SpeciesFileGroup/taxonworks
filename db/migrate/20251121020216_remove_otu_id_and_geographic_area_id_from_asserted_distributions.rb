class RemoveOtuIdAndGeographicAreaIdFromAssertedDistributions < ActiveRecord::Migration[7.2]
  def change
    # Remove foreign keys first
    remove_foreign_key :asserted_distributions, column: :otu_id, name: 'asserted_distributions_otu_id_fkey'
    remove_foreign_key :asserted_distributions, column: :geographic_area_id, name: 'asserted_distributions_geographic_area_id_fkey'

    # Remove indices
    remove_index :asserted_distributions, name: 'index_asserted_distributions_on_otu_id'
    remove_index :asserted_distributions, name: 'index_asserted_distributions_on_geographic_area_id'

    # Remove columns
    remove_column :asserted_distributions, :otu_id, :integer
    remove_column :asserted_distributions, :geographic_area_id, :integer
  end
end
