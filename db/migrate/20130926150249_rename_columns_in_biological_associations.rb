class RenameColumnsInBiologicalAssociations < ActiveRecord::Migration
  def change
    rename_column :biological_associations, :object_id, :biological_association_object_id
    rename_column :biological_associations, :subject_id, :biological_association_subject_id

  end
end
