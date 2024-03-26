class MakeBiocurationClassificationsPolymorphic < ActiveRecord::Migration[6.1]
  def change
    add_column :biocuration_classifications, :biocuration_classification_object_id, :bigint
    add_column :biocuration_classifications, :biocuration_classification_object_type, :string

    add_index :biocuration_classifications, [:biocuration_classification_object_type, :biocuration_classification_object_id], name: :bc_poly
  end
end
