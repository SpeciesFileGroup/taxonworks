class CreateBiologicalAssociationIndex < ActiveRecord::Migration[7.2]
  def change
    create_table :biological_association_indices do |t|
      # Core references
      t.references :biological_association, null: false, foreign_key: true, index: true
      t.references :biological_relationship, null: false, foreign_key: true, index: true
      t.references :project, null: false, foreign_key: true, index: true
      t.integer :created_by_id, null: false
      t.integer :updated_by_id, null: false

      t.integer :biological_association_uuid

      # Subject fields
      t.integer :subject_id, null: false
      t.string :subject_type, null: false
      t.string :subject_uuid
      t.string :subject_label
      t.string :subject_order
      t.string :subject_family
      t.string :subject_genus
      t.string :subject_properties

      # Relationship fields
      t.string :biological_relationship_uri
      t.string :relationship_name
      t.string :relationship_inverted_name

      # Object fields
      t.integer :object_id, null: false
      t.string :object_type, null: false
      t.string :object_uuid
      t.string :object_label
      t.string :object_order
      t.string :object_family
      t.string :object_genus
      t.string :object_properties

      # Citations and metadata
      t.text :citations
      t.string :citation_year
      t.string :established_date
      t.text :remarks

      t.timestamps
    end

    # Polymorphic indices
    add_index :biological_association_indices, [:subject_id, :subject_type]
    add_index :biological_association_indices, [:object_id, :object_type]

    # Relationship field indices
    add_index :biological_association_indices, :biological_relationship_uri
    add_index :biological_association_indices, :relationship_name
    add_index :biological_association_indices, :relationship_inverted_name

    # Subject indices (excluding label)
    add_index :biological_association_indices, :subject_order
    add_index :biological_association_indices, :subject_family
    add_index :biological_association_indices, :subject_genus
    add_index :biological_association_indices, :subject_properties

    # Object indices (excluding label)
    add_index :biological_association_indices, :object_order
    add_index :biological_association_indices, :object_family
    add_index :biological_association_indices, :object_genus
    add_index :biological_association_indices, :object_properties
  end
end
