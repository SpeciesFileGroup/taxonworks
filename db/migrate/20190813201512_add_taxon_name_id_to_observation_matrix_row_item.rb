class AddTaxonNameIdToObservationMatrixRowItem < ActiveRecord::Migration[5.2]
  def change
    add_reference :observation_matrix_row_items, :taxon_name, foreign_key: true
  end
end
