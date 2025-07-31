class RemoveOldFkfromTaxonDeterminations < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :taxon_determinations, column: :biological_collection_object_id, name: :taxon_determinations_biological_collection_object_id_fkey
  end
end
