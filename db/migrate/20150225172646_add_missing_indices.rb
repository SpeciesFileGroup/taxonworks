class AddMissingIndices < ActiveRecord::Migration
  def change

    add_index :alternate_values, :type
    add_index :alternate_values, :alternate_value_object_id
    add_index :alternate_values, :alternate_value_object_type
    add_index :alternate_values, :project_id

    add_index :biocuration_classifications, :position

    add_index :biological_associations, :biological_association_subject_type, name: :biol_assoc_subj_type
    add_index :biological_associations, :biological_association_object_type, name: :biol_assoc_obj_type
    add_index :biological_associations, :project_id

    add_index :biological_relationship_types, :type

    add_index :citations, :citation_object_type

    add_index :collection_objects, :type

    add_index :collection_profiles, :collection_type

    add_index :containers, :lft
    add_index :containers, :rgt
    add_index :containers, :type
    add_index :containers, :disposition

    add_index :container_items, :position
    add_index :container_items, :contained_object_type

    add_index :container_labels, :position

    add_index :contents, :type

    add_index :controlled_vocabulary_terms, :type

    add_index :data_attributes, :type
    add_index :data_attributes, :attribute_subject_type
    add_index :data_attributes, :project_id

    add_index :geographic_area_types, :name

    add_index :geographic_items, :type

    add_index :georeferences, :type
    add_index :georeferences, :position

    add_index :identifiers, :type

    add_index :images, :image_file_content_type

    add_index :loan_items, :position

    add_index :notes, :note_object_type

    add_index :otu_page_layout_sections, :type
    add_index :otu_page_layout_sections, :position

    add_index :people, :type

    add_index :pinboard_items, :position
    add_index :pinboard_items, :created_by_id
    add_index :pinboard_items, :updated_by_id

    add_index :project_sources, :project_id
    add_index :project_sources, :source_id
    add_index :project_sources, :created_by_id
    add_index :project_sources, :updated_by_id

    add_index :roles, :type
    add_index :roles, :role_object_type
    add_index :roles, :position

    add_index :serials, :translated_from_serial_id

    add_index :serial_chronologies, :updated_by_id
    add_index :serial_chronologies, :type

    add_index :sources, :type
    add_index :sources, :bibtex_type

    add_index :tags, :tag_object_type
    add_index :tags, :position

    add_index :tagged_section_keywords, :position

    add_index :taxon_determinations, :position

    add_index :taxon_names, :source_id
    add_index :taxon_names, :type

    add_index :taxon_name_classifications, :type

    add_index :taxon_name_relationships, :type

    add_index :type_materials, :type_type

  end
end
