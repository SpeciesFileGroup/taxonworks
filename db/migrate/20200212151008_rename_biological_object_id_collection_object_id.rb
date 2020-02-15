class RenameBiologicalObjectIdCollectionObjectId < ActiveRecord::Migration[6.0]
  def change
    rename_column :type_materials, :biological_object_id, :collection_object_id
  end
end
