class DataMigrationRemoveNullConstraintFromTaxonDetermination < ActiveRecord::Migration[6.1]
  def change
    change_column :taxon_determinations, :biological_collection_object_id, :bigint, null: true
  end
end
