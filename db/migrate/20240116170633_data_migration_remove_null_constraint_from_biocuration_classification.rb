class DataMigrationRemoveNullConstraintFromBiocurationClassification < ActiveRecord::Migration[6.1]
  def change
    change_column :biocuration_classifications, :biological_collection_object_id, :bigint, null: true
  end
end
