class AddIndices < ActiveRecord::Migration
  def change

    add_index :alternate_values, :alternate_object_id
    # add_foreign_key(:alternate_values, :alternate_objects, :alternate_object_id)
    add_index :alternate_values, :created_by_id
    # add_foreign_key(:alternate_values, :people, :created_by_id)
    add_index :alternate_values, :updated_by_id
    # add_foreign_key(:alternate_values, :people, :updated_by_id)
    add_index :asserted_distributions, :created_by_id
    # add_foreign_key(:asserted_distributions, :people, :created_by_id)
    add_index :asserted_distributions, :updated_by_id
    # add_foreign_key(:asserted_distributions, :people, :updated_by_id)

    add_index :biocuration_classifications, :biological_collection_object_id
    # I don't see a db table called BiologicalCollectionObjects but no complaints? Many more such examples. Is it a subclass?
    # add_foreign_key(:biocuration_classifications, :biological_collection_objects, :biological_collection_object_id)

    add_index :biocuration_classifications, :created_by_id
    # add_foreign_key(:biocuration_classifications, :people, :created_by_id)
    add_index :biocuration_classifications, :updated_by_id
    # add_foreign_key(:biocuration_classifications, :people, :updated_by_id)
    add_index :biocuration_classifications, :project_id
    # add_foreign_key(:biocuration_classifications, :projects, :project_id)
    add_index :biological_associations, :biological_association_subject_id
    # add_foreign_key(:biological_associations, :biological_association_subjects, :biological_association_subject_id)
    add_index :biological_associations, :biological_association_object_id
    # add_foreign_key(:biological_associations, :biological_association_objects, :biological_collection_object_id)
    add_index :biological_associations, :created_by_id
    # add_foreign_key(:biological_associations, :people, :created_by_id)
    add_index :biological_associations, :updated_by_id
    # add_foreign_key(:biological_associations, :people, :updated_by_id)
    add_index :biological_associations_biological_associations_graphs, :biological_associations_graph_id
    # add_foreign_key(:biological_associations_biological_associations_graphs, :biological_associations_graphs, :biological_associations_graph_id)
    add_index :biological_associations_biological_associations_graphs, :biological_association_id
    # add_foreign_key(:biological_associations_biological_associations_graphs, :biological_associations, :biological_association_id)
    add_index :biological_associations_biological_associations_graphs, :created_by_id
    # add_foreign_key(:biological_associations_biological_associations_graphs, :people, :created_by_id)
    add_index :biological_associations_biological_associations_graphs, :updated_by_id
    # add_foreign_key(:biological_associations_biological_associations_graphs, :people, :updated_by_id)
    add_index :biological_associations_biological_associations_graphs, :project_id
    # add_foreign_key(:biological_associations_biological_associations_graphs, :projects, :project_id)
    add_index :biological_associations_graphs, :created_by_id
    # add_foreign_key(:biological_associations_graphs, :people, :created_by_id)
    add_index :biological_associations_graphs, :updated_by_id
    # add_foreign_key(:biological_associations_graphs, :people, :updated_by_id)
    add_index :biological_associations_graphs, :project_id
    # add_foreign_key(:biological_associations_graphs, :projects, :project_id)
    add_index :biological_relationship_types, :biological_property_id
    # add_foreign_key(:biological_relationship_types, :biological_properties, :biological_property_id)
    add_index :biological_relationship_types, :biological_relationship_id
    # add_foreign_key(:biological_relationship_types, :biological_relationships, :biological_relationship_id)
    add_index :biological_relationship_types, :created_by_id
    # add_foreign_key(:biological_relationship_types, :people, :created_by_id)
    add_index :biological_relationship_types, :updated_by_id
    # add_foreign_key(:biological_relationship_types, :people, :updated_by_id)
    add_index :biological_relationship_types, :project_id
    # add_foreign_key(:biological_relationship_types, :projects, :project_id)
    add_index :biological_relationships, :created_by_id
    # add_foreign_key(:biological_relationships, :people, :created_by_id)
    add_index :biological_relationships, :updated_by_id
    # add_foreign_key(:biological_relationships, :people, :updated_by_id)
    add_index :biological_relationships, :project_id
    # add_foreign_key(:biological_relationships, :projects, :project_id)
    add_index :citation_topics, :created_by_id
    # add_foreign_key(:citation_topics, :people, :created_by_id)
    add_index :citation_topics, :updated_by_id
    # add_foreign_key(:citation_topics, :people, :updated_by_id)
    add_index :citation_topics, :project_id
    # add_foreign_key(:citation_topics, :projects, :project_id)
    add_index :citations, :citation_object_id
    # add_foreign_key(:citations, :citation_objects, :citation_object_id)
    add_index :citations, :source_id
    # add_foreign_key(:citations, :sources, :source_id)
    add_index :citations, :created_by_id
    # add_foreign_key(:citations, :people, :created_by_id)
    add_index :citations, :updated_by_id
    # add_foreign_key(:citations, :people, :updated_by_id)
    add_index :citations, :project_id
    # add_foreign_key(:citations, :projects, :project_id)
    add_index :collecting_events, :created_by_id
    # add_foreign_key(:collecting_events, :people, :created_by_id)
    add_index :collecting_events, :updated_by_id
    # add_foreign_key(:collecting_events, :people, :updated_by_id)
    add_index :collecting_events, :project_id
    # add_foreign_key(:collecting_events, :projects, :project_id)
    add_index :collection_objects, :preparation_type_id
    # add_foreign_key(:collection_objects, :preparation_types, :preparation_type_id)
    add_index :collection_objects, :repository_id
    # add_foreign_key(:collection_objects, :repositories, :repository_id)
    add_index :collection_objects, :created_by_id
    # add_foreign_key(:collection_objects, :people, :created_by_id)
    add_index :collection_objects, :updated_by_id
    # add_foreign_key(:collection_objects, :people, :updated_by_id)
    add_index :collection_objects, :project_id
    # add_foreign_key(:collection_objects, :projects, :project_id)
    add_index :collection_objects, :accession_provider_id
    # add_foreign_key(:collection_objects, :accession_providers, :accession_provider_id)
    add_index :collection_objects, :deaccession_recipient_id
    # add_foreign_key(:collection_objects, :deaccession_recipients, :deaccession_recipient_id)
    add_index :collection_profiles, :created_by_id
    # add_foreign_key(:collection_profiles, :people, :created_by_id)
    add_index :collection_profiles, :updated_by_id
    # add_foreign_key(:collection_profiles, :people, :updated_by_id)
    add_index :collection_profiles, :project_id
    # add_foreign_key()
    add_index :container_items, :contained_object_id
    # add_foreign_key(:container_items, :contained_objects, :contained_object_id)
    add_index :container_items, :created_by_id
    # add_foreign_key(:container_items, :people, :created_by_id
    add_index :container_items, :updated_by_id
    # add_foreign_key(:container_items, :people, :updated_by_id)
    add_index :container_items, :project_id
    # add_foreign_key(:container_items, :projects, :project_id)
    add_index :container_labels,:created_by_id
    # add_foreign_key(:container_labels, :people, :created_by_id)
    add_index :container_labels, :modified_by_id  # why not updated?
    # add_foreign_key(:container_labels, :people, :modified_by_id)
    add_index :container_labels, :project_id
    # add_foreign_key(:container_labels, :projects, :project_id)
    add_index :containers, :parent_id
    # add_foreign_key(:containers, :parents, :parent_id)
    add_index :containers, :created_by_id
    # add_foreign_key(:containers, :people, :created_by_id)
    add_index :containers, :updated_by_id
    # add_foreign_key(:containers, :people, :updated_by_id)
    add_index :containers, :project_id
    # add_foreign_key(:containers, :projects, :project_id)
    add_index :contents, :topic_id
    # add_foreign_key(:contents, :topics, :topic_id)
    add_index :contents, :created_by_id
    # add_foreign_key(:contents, :people, :created_by_id)
    add_index :contents, :updated_by_id
    # add_foreign_key(:contents, :people, :updated_by_id)
    add_index :contents, :project_id
    # add_foreign_key(:contents, :projects, :project_id)
    add_index :contents, :revision_id
    # add_foreign_key(:contents, :revisions, :revision_id)
    add_index :controlled_vocabulary_terms, :created_by_id
    # add_foreign_key(:controlled_vocabulary_terms, :people, :created_by_id)
    add_index :controlled_vocabulary_terms, :updated_by_id
    # add_foreign_key(:controlled_vocabulary_terms, :people, :updated_by_id)
    add_index :controlled_vocabulary_terms, :project_id
    # add_foreign_key(:controlled_vocabulary_terms, :projects, :project_id)
    add_index :data_attributes, :attribute_subject_id
    # add_foreign_key(:data_attributes, :attribute_subjects, :attribute_subject_id)
    add_index :data_attributes, :controlled_vocabulary_term_id
    # add_foreign_key(:data_attributes, :controlled_vocabulary_terms, :controlled_vocabulary_term_id)
    add_index :data_attributes, :created_by_id
    # add_foreign_key(:data_attributes, :people, :created_by_id)
    add_index :data_attributes, :updated_by_id
    # add_foreign_key(:data_attributes, :people, :updated_by_id)
    add_index :geographic_area_types, :created_by_id
    # add_foreign_key(:geographic_area_types, :people, :created_by_id)
    add_index :geographic_area_types, :updated_by_id
    # add_foreign_key(:geographic_area_types, :people, :updated_by_id)
    add_index :geographic_areas, :level0_id
    # add_foreign_key(:geographic_areas, :level0, :level0_id)
    add_index :geographic_areas, :level1_id
    # add_foreign_key(:geographic_areas, :level1, :level1_id)
    add_index :geographic_areas, :level2_id
    # add_foreign_key(:geographic_areas, :level2, :level2_id)
    add_index :geographic_areas, :tdwg_parent_id
    # add_foreign_key(:geographic_areas, :tdwg_parents, :tdwg_parent_id)
    add_index :geographic_areas, :tdwg_geo_item_id
    # add_foreign_key(:geographic_areas, :tdwg_geo_items, :tdwg_geo_item_id)
    # omitting tdwgID, gadmID, nelID
    add_index :geographic_areas, :created_by_id
    # add_foreign_key(:geographic_areas, :people, :created_by_id)
    add_index :geographic_areas, :updated_by_id
    # add_foreign_key(:geographic_areas, :people, :updated_by_id)
    add_index :geographic_areas, :ne_geo_item_id
    # add_foreign_key(:geographic_areas, :ne_geo_items, :ne_geo_item_id)
    add_index :geographic_items, :created_by_id
    # add_foreign_key(:geographic_items, :people, :created_by_id)
    add_index :geographic_items, :updated_by_id
    # add_foreign_key(:geographic_items, :people, :updated_by_id)
    add_index :georeferences, :geographic_item_id
    # add_foreign_key(:georeferences, :geographic_items, :geographic_item_id)
    add_index :georeferences, :collecting_event_id
    # add_foreign_key(:georeferences, :collecting_events, :collecting_event_id)
    add_index :georeferences, :error_geographic_item_id
    # add_foreign_key(:georeferences, :error_geographic_items, :error_geographic_item_id)
    add_index :georeferences, :source_id
    # add_foreign_key(:georeferences, :sources, :source_id)
    add_index :georeferences, :created_by_id
    # add_foreign_key(:georeferences, :people, :created_by_id)
    add_index :georeferences, :updated_by_id
    # add_foreign_key(:georeferences, :people, :updated_by_id)
    add_index :georeferences, :project_id
    # add_foreign_key(:georeferences, :projects, :project_id)
    add_index :identifiers, :identified_object_id
    # add_foreign_key(:identifiers, :identified_objects, :identified_object_id)
    add_index :identifiers, :namespace_id
    # add_foreign_key(:identifiers, :namespaces, :namespace_id)
    add_index :identifiers, :created_by_id
    # add_foreign_key(:identifiers, :people, :created_by_id)
    add_index :identifiers, :updated_by_id
    # add_foreign_key(:identifiers, :people, :updated_by_id)
    add_index :identifiers, :project_id
    # add_foreign_key(:identifiers, :projects, :project_id)
    add_index :images, :created_by_id
    # add_foreign_key(:images, :people, :created_by_id)
    add_index :images, :project_id
    # add_foreign_key(:images, :projects, :project_id)
    add_index :images, :updated_by_id
    # add_foreign_key(:images, :people, :updated_by_id)
    add_index :languages, :created_by_id
    # add_foreign_key(:languages, :people, :created_by_id)
    add_index :languages, :updated_by_id
    # add_foreign_key(:languages, :people, :updated_by_id)
    add_index :loan_items, :created_by_id
    # add_foreign_key(:loan_items, :people, :created_by_id)
    add_index :loan_items, :updated_by_id
    # add_foreign_key(:loan_items, :people, :updated_by_id)
    add_index :loan_items, :project_id
    # add_foreign_key(:loan_items, :projects, :project_id)
    add_index :loan_items, :container_id
    # add_foreign_key(:loan_items, :containers, :container_id)
    add_index :loans, :recipient_person_id
    # add_foreign_key(:loans, :people, :recipient_person_id)
    add_index :loans, :supervisor_person_id
    # add_foreign_key(:loans, :people, :supervisor_person_id)
    add_index :loans, :created_by_id
    # add_foreign_key(:loans, :people, :created_by_id)
    add_index :loans, :updated_by_id
    # add_foreign_key(:loans, :people, :updated_by_id)
    add_index :loans, :project_id
    # add_foreign_key(:loans, :projects, :project_id)
    add_index :namespaces, :created_by_id
    # add_foreign_key(:namespaces, :people, :created_by_id)
    add_index :namespaces, :updated_by_id
    # add_foreign_key(:namespaces, :people, :updated_by_id)
    add_index :notes, :note_object_id
    # add_foreign_key(:notes, :note_objects, :note_object_id)
    add_index :notes, :created_by_id
    # add_foreign_key(:notes, :people, :created_by_id)
    add_index :notes, :updated_by_id
    # add_foreign_key(:notes, :people, :updated_by_id)
    add_index :notes, :project_id
    # add_foreign_key(:notes, :projects, :project_id)
    add_index :otu_page_layout_sections, :created_by_id
    # add_foreign_key(:otu_page_layout_sections, :people, :created_by_id)
    add_index :otu_page_layout_sections, :updated_by_id
    # add_foreign_key(:otu_page_layout_sections, :people, :updated_by_id)
    add_index :otu_page_layout_sections, :project_id
    # add_foreign_key(:otu_page_layout_sections, :projects, :project_id)
    add_index :otu_page_layouts, :created_by_id
    # add_foreign_key(:otu_page_layouts, :people, :created_by_id)
    add_index :otu_page_layouts, :updated_by_id
    # add_foreign_key(:otu_page_layouts, :people, :updated_by_id)
    add_index :otu_page_layouts, :project_id
    # add_foreign_key(:otu_page_layouts, :projects, :project_id)
    add_index :otus, :created_by_id
    # add_foreign_key(:otus, :people, :created_by_id)
    add_index :otus, :updated_by_id
    # add_foreign_key(:otus, :people, :updated_by_id)
    add_index :otus, :project_id
    # add_foreign_key(:otus, :projects, :project_id)
    add_index :people, :created_by_id
    # add_foreign_key(:people, :people, :created_by_id)
    add_index :people, :updated_by_id
    # add_foreign_key(:people, :people, :updated_by_id)
    add_index :preparation_types, :created_by_id
    # add_foreign_key(:preparation_types, :people, :created_by_id)
    add_index :preparation_types, :updated_by_id
    # add_foreign_key(:preparation_types, :people, :updated_by_id)
    add_index :project_members, :project_id
    # add_foreign_key(:project_members, :projects, :project_id)
    add_index :project_members, :user_id
    # add_foreign_key(:project_members, :users, :user_id)
    add_index :project_members, :created_by_id
    # add_foreign_key(:project_members, :people, :created_by_id)
    add_index :project_members, :updated_by_id
    # add_foreign_key(:project_members, :people, :updated_by_id)
    add_index :projects, :created_by_id
    # add_foreign_key(:projects, :people, :created_by_id)
    add_index :projects, :updated_by_id
    # add_foreign_key(:projects, :people, :updated_by_id)
    add_index :projects_sources, :created_by_id
    # add_foreign_key(:projects_sources, :people, :created_by_id)
    add_index :projects_sources, :updated_by_id
    # add_foreign_key(:projects_sources, :people, :updated_by_id)
    add_index :public_contents, :created_by_id
    # add_foreign_key(:public_contents, :people, :created_by_id)
    add_index :public_contents, :updated_by_id
    # add_foreign_key(:public_contents, :people, :updated_by_id)
    add_index :public_contents, :content_id
    # add_foreign_key(:public_contents, :contents, :content_id)
    add_index :ranged_lot_categories, :created_by_id
    # add_foreign_key(:ranged_lot_categories, :people, :created_by_id)
    add_index :ranged_lot_categories, :updated_by_id
    # add_foreign_key(:ranged_lot_categories, :people, :updated_by_id)
    add_index :ranged_lot_categories, :project_id
    # add_foreign_key(:ranged_lot_categories, :projects, :project_id)
    add_index :repositories, :created_by_id
    # add_foreign_key(:repositories, :people, :created_by_id)
    add_index :repositories, :updated_by_id
    # add_foreign_key(:repositories, :people, :updated_by_id)
    add_index :roles, :role_object_id
    # add_foreign_key(:roles, :role_objects, :role_object_id
    add_index :roles, :created_by_id
    # add_foreign_key(:roles, :people, :created_by_id)
    add_index :roles, :updated_by_id
    # add_foreign_key(:roles, :people, :updated_by_id)
    add_index :roles, :project_id
    # add_foreign_key(:roles, :projects, :project_id)
    add_index :serial_chronologies, :preceding_serial_id
    # add_foreign_key(:serial_chronologies, :preceding_serials, :preceding_serial_id)
    add_index :serial_chronologies, :succeeding_serial_id
    # add_foreign_key(:serial_chronologies, :succeeding_serials, :succeeding_serial_id
    add_index :serial_chronologies, :created_by_id
    # add_foreign_key(:serial_chronologies, :people, :created_by_id)
    add_index :serial_chronologies, :modified_by_id
    # add_foreign_key(:serial_chronologies, :people, :modified_by_id)
    add_index :serials, :created_by_id
    # add_foreign_key(:serials, :people, :created_by_id)
    add_index :serials, :updated_by_id
    # add_foreign_key(:serials, :people, :updated_by_id)
    add_index :serials, :project_id
    # add_foreign_key(:serials, :projects, :project_id)
    add_index :serials, :primary_language_id
    # add_foreign_key(:serials, :primary_languages, :primary_language_id)
    add_index :sources, :created_by_id
    # add_foreign_key(:sources, :people, :created_by_id)
    add_index :sources, :updated_by_id
    # add_foreign_key(:sources, :people, :updated_by_id)
    add_index :sources, :language_id
    # add_foreign_key(:sources, :languages, :language_id)

    # no creator/updater for SpecimenDeterminations?

    add_index :tagged_section_keywords, :created_by_id
    # add_foreign_key(:tagged_section_keywords, :people, :created_by_id)
    add_index :tagged_section_keywords, :updated_by_id
    # add_foreign_key(:tagged_section_keywords, :people, :updated_by_id)
    add_index :tagged_section_keywords, :keyword_id
    # add_foreign_key(:tagged_section_keywords, :keywords, :keyword_id)
    add_index :tags, :tag_object_id
    # add_foreign_key(:tags, :tag_objects, :tag_object_id)
    add_index :tags, :created_by_id
    # add_foreign_key(:tags, :people, :created_by_id)
    add_index :tags, :updated_by_id
    # add_foreign_key(:tags, :people, :updated_by_id)
    add_index :tags, :project_id
    # add_foreign_key(:tags, :projects, :project_id)
    add_index :taxon_determinations, :biological_collection_object_id
    # add_foreign_key(:taxon_determinations, :biological_collection_objects, :biological_collection_object_id)
    add_index :taxon_determinations, :created_by_id
    # add_foreign_key(:taxon_determinations, :people, :created_by_id)
    add_index :taxon_determinations, :updated_by_id
    # add_foreign_key(:taxon_determinations, :people, :updated_by_id)
    add_index :taxon_determinations, :project_id
    # add_foreign_key(:taxon_determinations, :projects, :project_id)
    add_index :taxon_name_classifications, :created_by_id
    # add_foreign_key(:taxon_name_classifications, :people, :created_by_id)
    add_index :taxon_name_classifications, :updated_by_id
    # add_foreign_key(:taxon_name_classifications, :people, :updated_by_id)
    add_index :taxon_name_classifications, :project_id
    # add_foreign_key(:taxon_name_classifications, :projects, :project_id)
    add_index :taxon_name_relationships, :subject_taxon_name_id
    # add_foreign_key(:taxon_name_relationships, :subject_taxon_names, :subject_taxon_name_id)
    add_index :taxon_name_relationships, :object_taxon_name_id
    # add_foreign_key(:taxon_name_relationships, :object_taxon_names, :object_taxon_name_id)
    add_index :taxon_name_relationships, :created_by_id
    # add_foreign_key(:taxon_name_relationships, :people, :created_by_id)
    add_index :taxon_name_relationships, :updated_by_id
    # add_foreign_key(:taxon_name_relationships, :people, :updated_by_id)
    add_index :taxon_name_relationships, :project_id
    # add_foreign_key(:taxon_name_relationships, :projects, :project_id)
    add_index :taxon_name_relationships, :source_id
    # add_foreign_key(:taxon_name_relationships, :sources, :source_id)
    add_index :taxon_names, :created_by_id
    # add_foreign_key(:taxon_names, :people, :created_by_id)
    add_index :taxon_names, :updated_by_id
    # add_foreign_key(:taxon_names, :people, :updated_by_id)
    add_index :test_classes, :project_id
    # add_foreign_key(:test_classes, :projects, :project_id)
    add_index :test_classes, :created_by_id
    # add_foreign_key(:test_classes, :people, :created_by_id)
    add_index :test_classes, :updated_by_id
    # add_foreign_key(:test_classes, :people, :updated_by_id)
    add_index :type_materials, :protonym_id
    # add_foreign_key(:type_materials, :protonyms, :protonym_id)
    add_index :type_materials, :biological_object_id
    # add_foreign_key(:type_materials, :biological_objects, :biological_object_id)
    add_index :type_materials, :created_by_id
    # add_foreign_key(:type_materials, :people, :created_by_id)
    add_index :type_materials, :updated_by_id
    # add_foreign_key(:type_materials, :people, :updated_by_id)
    add_index :type_materials, :project_id
    # add_foreign_key(:type_materials, :projects, :project_id)
    add_index :users, :created_by_id
    # add_foreign_key(:users, :people, :created_by_id)
    add_index :users, :updated_by_id
    # add_foreign_key(:users, :people, :updated_by_id)
  end
end
