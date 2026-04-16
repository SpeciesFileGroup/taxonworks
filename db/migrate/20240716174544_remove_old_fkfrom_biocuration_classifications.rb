class RemoveOldFkfromBiocurationClassifications < ActiveRecord::Migration[7.1]
  def change
    remove_foreign_key :biocuration_classifications, column: :biological_collection_object_id, name: :biocuration_classifications_biological_collection_object_i_fkey
  end
end
