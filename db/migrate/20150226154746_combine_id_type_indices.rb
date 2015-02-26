class CombineIdTypeIndices < ActiveRecord::Migration
  def change

    remove_index :alternate_values, :alternate_value_object_id
    remove_index :alternate_values, :alternate_value_object_type
    add_index :alternate_values, [:alternate_value_object_id, :alternate_value_object_type], name: :index_alternate_values_on_alternate_value_object_id_and_type

    remove_index :biological_associations, name: :bio_asc_bio_asc_subject
    remove_index :biological_associations, name: :biol_assoc_subj_type
    add_index :biological_associations, [:biological_association_subject_id, :biological_association_subject_type], name: :index_biological_associations_on_subject_id_and_type

    remove_index :biological_associations, name: :bio_asc_bio_asc_object
    remove_index :biological_associations, name: :biol_assoc_obj_type
    add_index :biological_associations, [:biological_association_object_id, :biological_association_object_type], name: :index_biological_associations_on_object_id_and_type

    remove_index :container_items, :contained_object_id
    remove_index :container_items, :contained_object_type
    add_index :container_items, [:contained_object_id, :contained_object_type], name: :index_container_items_on_contained_object_id_and_type

    remove_index :data_attributes, :attribute_subject_id
    remove_index :data_attributes, :attribute_subject_type
    add_index :data_attributes, [:attribute_subject_id, :attribute_subject_type], name: :index_data_attributes_on_attribute_subject_id_and_type

    remove_index :identifiers, :identifier_object_id
    remove_index :identifiers, :identifier_object_type
    add_index :identifiers, [:identifier_object_id, :identifier_object_type], name: :index_identifiers_on_identifier_object_id_and_type

    remove_index :notes, :note_object_id
    remove_index :notes, :note_object_type
    add_index :notes, [:note_object_id, :note_object_type], name: :index_notes_on_note_object_id_and_type

    remove_index :roles, :role_object_id
    remove_index :roles, :role_object_type
    add_index :roles, [:role_object_id, :role_object_type], name: :index_roles_on_role_object_id_and_type

    remove_index :tags, :tag_object_id
    remove_index :tags, :tag_object_type
    add_index :tags, [:tag_object_id, :tag_object_type], name: :index_tags_on_tag_object_id_and_type

  end
end
