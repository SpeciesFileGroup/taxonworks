class RenameBiologicalAssociationTypeColumns < ActiveRecord::Migration
  def change
    rename_column :biological_associations, :object_type, :biological_association_object_type
    rename_column :biological_associations, :subject_type, :biological_association_subject_type
    remove_column :biological_associations, :biological_associations_graph_id
  end
end
