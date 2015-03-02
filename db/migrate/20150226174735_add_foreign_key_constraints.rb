class AddForeignKeyConstraints < ActiveRecord::Migration
  def change

    AlternateValue.connection.execute('alter table alternate_values add foreign key (language_id) references languages (id);')
    AlternateValue.connection.execute('alter table alternate_values add foreign key (created_by_id) references users (id);')
    AlternateValue.connection.execute('alter table alternate_values add foreign key (updated_by_id) references users (id);')
    AlternateValue.connection.execute('alter table alternate_values add foreign key (project_id) references projects (id);')

    AssertedDistribution.connection.execute('alter table asserted_distributions add foreign key (otu_id) references otus (id);')
    AssertedDistribution.connection.execute('alter table asserted_distributions add foreign key (geographic_area_id) references geographic_areas (id);')
    AssertedDistribution.connection.execute('alter table asserted_distributions add foreign key (source_id) references sources (id);')
    AssertedDistribution.connection.execute('alter table asserted_distributions add foreign key (project_id) references projects (id);')
    AssertedDistribution.connection.execute('alter table asserted_distributions add foreign key (created_by_id) references users (id);')
    AssertedDistribution.connection.execute('alter table asserted_distributions add foreign key (updated_by_id) references users (id);')

    BiocurationClassification.connection.execute('alter table biocuration_classifications add foreign key (biocuration_class_id) references controlled_vocabulary_terms (id);')
    BiocurationClassification.connection.execute('alter table biocuration_classifications add foreign key (biological_collection_object_id) references collection_objects (id);')
    BiocurationClassification.connection.execute('alter table biocuration_classifications add foreign key (created_by_id) references users (id);')
    BiocurationClassification.connection.execute('alter table biocuration_classifications add foreign key (updated_by_id) references users (id);')
    BiocurationClassification.connection.execute('alter table biocuration_classifications add foreign key (project_id) references projects (id);')

    BiologicalAssociation.connection.execute('alter table biological_associations add foreign key (biological_relationship_id) references biological_relationships (id);')
    BiologicalAssociation.connection.execute('alter table biological_associations add foreign key (created_by_id) references users (id);')
    BiologicalAssociation.connection.execute('alter table biological_associations add foreign key (updated_by_id) references users (id);')
    BiologicalAssociation.connection.execute('alter table biological_associations add foreign key (project_id) references projects (id);')

    BiologicalAssociationsBiologicalAssociationsGraph.connection.execute('alter table biological_associations_biological_associations_graphs add foreign key (biological_associations_graph_id) references biological_associations_graphs (id);')
    BiologicalAssociationsBiologicalAssociationsGraph.connection.execute('alter table biological_associations_biological_associations_graphs add foreign key (biological_association_id) references biological_associations (id);')
    BiologicalAssociationsBiologicalAssociationsGraph.connection.execute('alter table biological_associations_biological_associations_graphs add foreign key (created_by_id) references users (id);')
    BiologicalAssociationsBiologicalAssociationsGraph.connection.execute('alter table biological_associations_biological_associations_graphs add foreign key (updated_by_id) references users (id);')
    BiologicalAssociationsBiologicalAssociationsGraph.connection.execute('alter table biological_associations_biological_associations_graphs add foreign key (project_id) references projects (id);')

    BiologicalAssociationsGraph.connection.execute('alter table biological_associations_graphs add foreign key (created_by_id) references users (id);')
    BiologicalAssociationsGraph.connection.execute('alter table biological_associations_graphs add foreign key (updated_by_id) references users (id);')
    BiologicalAssociationsGraph.connection.execute('alter table biological_associations_graphs add foreign key (project_id) references projects (id);')
    BiologicalAssociationsGraph.connection.execute('alter table biological_associations_graphs add foreign key (source_id) references sources (id);')

    BiologicalRelationship.connection.execute('alter table biological_relationships add foreign key (created_by_id) references users (id);')
    BiologicalRelationship.connection.execute('alter table biological_relationships add foreign key (updated_by_id) references users (id);')
    BiologicalRelationship.connection.execute('alter table biological_relationships add foreign key (project_id) references projects (id);')

    BiologicalRelationshipType.connection.execute('alter table biological_relationship_types add foreign key (biological_property_id) references controlled_vocabulary_terms (id);')
    BiologicalRelationshipType.connection.execute('alter table biological_relationship_types add foreign key (biological_relationship_id) references biological_relationships (id);')
    BiologicalRelationshipType.connection.execute('alter table biological_relationship_types add foreign key (created_by_id) references users (id);')
    BiologicalRelationshipType.connection.execute('alter table biological_relationship_types add foreign key (updated_by_id) references users (id);')
    BiologicalRelationshipType.connection.execute('alter table biological_relationship_types add foreign key (project_id) references projects (id);')

    Citation.connection.execute('alter table citations add foreign key (source_id) references sources (id);')
    Citation.connection.execute('alter table citations add foreign key (created_by_id) references users (id);')
    Citation.connection.execute('alter table citations add foreign key (updated_by_id) references users (id);')
    Citation.connection.execute('alter table citations add foreign key (project_id) references projects (id);')

    CitationTopic.connection.execute('alter table citation_topics add foreign key (topic_id) references controlled_vocabulary_terms (id);')
    CitationTopic.connection.execute('alter table citation_topics add foreign key (citation_id) references citations (id);')
    CitationTopic.connection.execute('alter table citation_topics add foreign key (created_by_id) references users (id);')
    CitationTopic.connection.execute('alter table citation_topics add foreign key (updated_by_id) references users (id);')
    CitationTopic.connection.execute('alter table citation_topics add foreign key (project_id) references projects (id);')

    CollectingEvent.connection.execute('alter table collecting_events add foreign key (geographic_area_id) references geographic_areas (id);')
    CollectingEvent.connection.execute('alter table collecting_events add foreign key (created_by_id) references users (id);')
    CollectingEvent.connection.execute('alter table collecting_events add foreign key (updated_by_id) references users (id);')
    CollectingEvent.connection.execute('alter table collecting_events add foreign key (project_id) references projects (id);')

    CollectionObject.connection.execute('alter table collection_objects add foreign key (preparation_type_id) references preparation_types (id);')
    CollectionObject.connection.execute('alter table collection_objects add foreign key (repository_id) references repositories (id);')
    CollectionObject.connection.execute('alter table collection_objects add foreign key (created_by_id) references users (id);')
    CollectionObject.connection.execute('alter table collection_objects add foreign key (updated_by_id) references users (id);')
    CollectionObject.connection.execute('alter table collection_objects add foreign key (project_id) references projects (id);')
    CollectionObject.connection.execute('alter table collection_objects add foreign key (ranged_lot_category_id) references ranged_lot_categories (id);')
    CollectionObject.connection.execute('alter table collection_objects add foreign key (collecting_event_id) references collecting_events (id);')

    CollectionProfile.connection.execute('alter table collection_profiles add foreign key (container_id) references containers (id);')
    CollectionProfile.connection.execute('alter table collection_profiles add foreign key (otu_id) references otus (id);')
    CollectionProfile.connection.execute('alter table collection_profiles add foreign key (created_by_id) references users (id);')
    CollectionProfile.connection.execute('alter table collection_profiles add foreign key (updated_by_id) references users (id);')
    CollectionProfile.connection.execute('alter table collection_profiles add foreign key (project_id) references projects (id);')

    Container.connection.execute('alter table containers add foreign key (parent_id) references containers (id);')
    Container.connection.execute('alter table containers add foreign key (created_by_id) references users (id);')
    Container.connection.execute('alter table containers add foreign key (updated_by_id) references users (id);')
    Container.connection.execute('alter table containers add foreign key (project_id) references projects (id);')
    Container.connection.execute('alter table containers add foreign key (otu_id) references otus (id);')

    ContainerItem.connection.execute('alter table container_items add foreign key (container_id) references containers (id);')
    ContainerItem.connection.execute('alter table container_items add foreign key (created_by_id) references users (id);')
    ContainerItem.connection.execute('alter table container_items add foreign key (updated_by_id) references users (id);')
    ContainerItem.connection.execute('alter table container_items add foreign key (project_id) references projects (id);')

    ContainerLabel.connection.execute('alter table container_labels add foreign key (created_by_id) references users (id);')
    ContainerLabel.connection.execute('alter table container_labels add foreign key (updated_by_id) references users (id);')
    ContainerLabel.connection.execute('alter table container_labels add foreign key (project_id) references projects (id);')
    ContainerLabel.connection.execute('alter table container_labels add foreign key (container_id) references containers (id);')

    Content.connection.execute('alter table contents add foreign key (otu_id) references otus (id);')
    Content.connection.execute('alter table contents add foreign key (topic_id) references controlled_vocabulary_terms (id);')
    Content.connection.execute('alter table contents add foreign key (created_by_id) references users (id);')
    Content.connection.execute('alter table contents add foreign key (updated_by_id) references users (id);')
    Content.connection.execute('alter table contents add foreign key (project_id) references projects (id);')

    ControlledVocabularyTerm.connection.execute('alter table controlled_vocabulary_terms add foreign key (created_by_id) references users (id);')
    ControlledVocabularyTerm.connection.execute('alter table controlled_vocabulary_terms add foreign key (updated_by_id) references users (id);')
    ControlledVocabularyTerm.connection.execute('alter table controlled_vocabulary_terms add foreign key (project_id) references projects (id);')

    DataAttribute.connection.execute('alter table data_attributes add foreign key (controlled_vocabulary_term_id) references controlled_vocabulary_terms (id);')
    DataAttribute.connection.execute('alter table data_attributes add foreign key (created_by_id) references users (id);')
    DataAttribute.connection.execute('alter table data_attributes add foreign key (updated_by_id) references users (id);')
    DataAttribute.connection.execute('alter table data_attributes add foreign key (project_id) references projects (id);')

    GeographicArea.connection.execute('alter table geographic_areas add foreign key (level0_id) references geographic_areas (id);')
    GeographicArea.connection.execute('alter table geographic_areas add foreign key (level1_id) references geographic_areas (id);')
    GeographicArea.connection.execute('alter table geographic_areas add foreign key (level2_id) references geographic_areas (id);')
    GeographicArea.connection.execute('alter table geographic_areas add foreign key (parent_id) references geographic_areas (id);')
    GeographicArea.connection.execute('alter table geographic_areas add foreign key (geographic_area_type_id) references geographic_area_types (id);')
    GeographicArea.connection.execute('alter table geographic_areas add foreign key (created_by_id) references users (id);')
    GeographicArea.connection.execute('alter table geographic_areas add foreign key (updated_by_id) references users (id);')

    GeographicAreaType.connection.execute('alter table geographic_area_types add foreign key (created_by_id) references users (id);')
    GeographicAreaType.connection.execute('alter table geographic_area_types add foreign key (updated_by_id) references users (id);')

    GeographicAreasGeographicItem.connection.execute('alter table geographic_areas_geographic_items add foreign key (geographic_area_id) references geographic_areas (id);')
    GeographicAreasGeographicItem.connection.execute('alter table geographic_areas_geographic_items add foreign key (geographic_item_id) references geographic_items (id);')

    GeographicItem.connection.execute('alter table geographic_items add foreign key (created_by_id) references users (id);')
    GeographicItem.connection.execute('alter table geographic_items add foreign key (updated_by_id) references users (id);')

    Georeference.connection.execute('alter table georeferences add foreign key (geographic_item_id) references geographic_items (id);')
    Georeference.connection.execute('alter table georeferences add foreign key (collecting_event_id) references collecting_events (id);')
    Georeference.connection.execute('alter table georeferences add foreign key (error_geographic_item_id) references geographic_items (id);')
    Georeference.connection.execute('alter table georeferences add foreign key (source_id) references sources (id);')
    Georeference.connection.execute('alter table georeferences add foreign key (created_by_id) references users (id);')
    Georeference.connection.execute('alter table georeferences add foreign key (updated_by_id) references users (id);')
    Georeference.connection.execute('alter table georeferences add foreign key (project_id) references projects (id);')

    Identifier.connection.execute('alter table identifiers add foreign key (namespace_id) references namespaces (id);')
    Identifier.connection.execute('alter table identifiers add foreign key (created_by_id) references users (id);')
    Identifier.connection.execute('alter table identifiers add foreign key (updated_by_id) references users (id);')
    Identifier.connection.execute('alter table identifiers add foreign key (project_id) references projects (id);')

    Image.connection.execute('alter table images add foreign key (created_by_id) references users (id);')
    Image.connection.execute('alter table images add foreign key (project_id) references projects (id);')
    Image.connection.execute('alter table images add foreign key (updated_by_id) references users (id);')

    Language.connection.execute('alter table languages add foreign key (created_by_id) references users (id);')
    Language.connection.execute('alter table languages add foreign key (updated_by_id) references users (id);')

    Loan.connection.execute('alter table loans add foreign key (recipient_person_id) references people (id);')
    Loan.connection.execute('alter table loans add foreign key (created_by_id) references users (id);')
    Loan.connection.execute('alter table loans add foreign key (updated_by_id) references users (id);')
    Loan.connection.execute('alter table loans add foreign key (project_id) references projects (id);')

    LoanItem.connection.execute('alter table loan_items add foreign key (loan_id) references loans (id);')
    LoanItem.connection.execute('alter table loan_items add foreign key (collection_object_id) references collection_objects (id);')
    LoanItem.connection.execute('alter table loan_items add foreign key (created_by_id) references users (id);')
    LoanItem.connection.execute('alter table loan_items add foreign key (updated_by_id) references users (id);')
    LoanItem.connection.execute('alter table loan_items add foreign key (project_id) references projects (id);')
    LoanItem.connection.execute('alter table loan_items add foreign key (container_id) references containers (id);')

    Namespace.connection.execute('alter table namespaces add foreign key (created_by_id) references users (id);')
    Namespace.connection.execute('alter table namespaces add foreign key (updated_by_id) references users (id);')

    Note.connection.execute('alter table notes add foreign key (created_by_id) references users (id);')
    Note.connection.execute('alter table notes add foreign key (updated_by_id) references users (id);')
    Note.connection.execute('alter table notes add foreign key (project_id) references projects (id);')

    Otu.connection.execute('alter table otus add foreign key (created_by_id) references users (id);')
    Otu.connection.execute('alter table otus add foreign key (updated_by_id) references users (id);')
    Otu.connection.execute('alter table otus add foreign key (project_id) references projects (id);')
    Otu.connection.execute('alter table otus add foreign key (taxon_name_id) references taxon_names (id);')

    OtuPageLayout.connection.execute('alter table otu_page_layouts add foreign key (created_by_id) references users (id);')
    OtuPageLayout.connection.execute('alter table otu_page_layouts add foreign key (updated_by_id) references users (id);')
    OtuPageLayout.connection.execute('alter table otu_page_layouts add foreign key (project_id) references projects (id);')

    OtuPageLayoutSection.connection.execute('alter table otu_page_layout_sections add foreign key (otu_page_layout_id) references otu_page_layouts (id);')
    OtuPageLayoutSection.connection.execute('alter table otu_page_layout_sections add foreign key (topic_id) references controlled_vocabulary_terms (id);')
    OtuPageLayoutSection.connection.execute('alter table otu_page_layout_sections add foreign key (created_by_id) references users (id);')
    OtuPageLayoutSection.connection.execute('alter table otu_page_layout_sections add foreign key (updated_by_id) references users (id);')
    OtuPageLayoutSection.connection.execute('alter table otu_page_layout_sections add foreign key (project_id) references projects (id);')

    Person.connection.execute('alter table people add foreign key (created_by_id) references users (id);')
    Person.connection.execute('alter table people add foreign key (updated_by_id) references users (id);')

    PinboardItem.connection.execute('alter table pinboard_items add foreign key (user_id) references users (id);')
    PinboardItem.connection.execute('alter table pinboard_items add foreign key (project_id) references projects (id);')
    PinboardItem.connection.execute('alter table pinboard_items add foreign key (created_by_id) references users (id);')
    PinboardItem.connection.execute('alter table pinboard_items add foreign key (updated_by_id) references users (id);')

    PreparationType.connection.execute('alter table preparation_types add foreign key (created_by_id) references users (id);')
    PreparationType.connection.execute('alter table preparation_types add foreign key (updated_by_id) references users (id);')

    Project.connection.execute('alter table projects add foreign key (created_by_id) references users (id);')
    Project.connection.execute('alter table projects add foreign key (updated_by_id) references users (id);')

    ProjectMember.connection.execute('alter table project_members add foreign key (project_id) references projects (id);')
    ProjectMember.connection.execute('alter table project_members add foreign key (user_id) references users (id);')
    ProjectMember.connection.execute('alter table project_members add foreign key (created_by_id) references users (id);')
    ProjectMember.connection.execute('alter table project_members add foreign key (updated_by_id) references users (id);')

    ProjectSource.connection.execute('alter table project_sources add foreign key (project_id) references projects (id);')
    ProjectSource.connection.execute('alter table project_sources add foreign key (source_id) references sources (id);')
    ProjectSource.connection.execute('alter table project_sources add foreign key (created_by_id) references users (id);')
    ProjectSource.connection.execute('alter table project_sources add foreign key (updated_by_id) references users (id);')

    PublicContent.connection.execute('alter table public_contents add foreign key (otu_id) references otus (id);')
    PublicContent.connection.execute('alter table public_contents add foreign key (topic_id) references controlled_vocabulary_terms (id);')
    PublicContent.connection.execute('alter table public_contents add foreign key (project_id) references projects (id);')
    PublicContent.connection.execute('alter table public_contents add foreign key (created_by_id) references users (id);')
    PublicContent.connection.execute('alter table public_contents add foreign key (updated_by_id) references users (id);')
    PublicContent.connection.execute('alter table public_contents add foreign key (content_id) references contents (id);')

    RangedLotCategory.connection.execute('alter table ranged_lot_categories add foreign key (created_by_id) references users (id);')
    RangedLotCategory.connection.execute('alter table ranged_lot_categories add foreign key (updated_by_id) references users (id);')
    RangedLotCategory.connection.execute('alter table ranged_lot_categories add foreign key (project_id) references projects (id);')

    Repository.connection.execute('alter table repositories add foreign key (created_by_id) references users (id);')
    Repository.connection.execute('alter table repositories add foreign key (updated_by_id) references users (id);')

    Role.connection.execute('alter table roles add foreign key (person_id) references people (id);')
    Role.connection.execute('alter table roles add foreign key (created_by_id) references users (id);')
    Role.connection.execute('alter table roles add foreign key (updated_by_id) references users (id);')
    Role.connection.execute('alter table roles add foreign key (project_id) references projects (id);')

    Serial.connection.execute('alter table serials add foreign key (created_by_id) references users (id);')
    Serial.connection.execute('alter table serials add foreign key (updated_by_id) references users (id);')
    Serial.connection.execute('alter table serials add foreign key (primary_language_id) references languages (id);')
    Serial.connection.execute('alter table serials add foreign key (translated_from_serial_id) references serials (id);')

    SerialChronology.connection.execute('alter table serial_chronologies add foreign key (preceding_serial_id) references serials (id);')
    SerialChronology.connection.execute('alter table serial_chronologies add foreign key (succeeding_serial_id) references serials (id);')
    SerialChronology.connection.execute('alter table serial_chronologies add foreign key (created_by_id) references users (id);')
    SerialChronology.connection.execute('alter table serial_chronologies add foreign key (updated_by_id) references users (id);')

    Source.connection.execute('alter table sources add foreign key (serial_id) references serials (id);')
    Source.connection.execute('alter table sources add foreign key (created_by_id) references users (id);')
    Source.connection.execute('alter table sources add foreign key (updated_by_id) references users (id);')
    Source.connection.execute('alter table sources add foreign key (language_id) references languages (id);')

    Tag.connection.execute('alter table tags add foreign key (keyword_id) references controlled_vocabulary_terms (id);')
    Tag.connection.execute('alter table tags add foreign key (created_by_id) references users (id);')
    Tag.connection.execute('alter table tags add foreign key (updated_by_id) references users (id);')
    Tag.connection.execute('alter table tags add foreign key (project_id) references projects (id);')

    TaggedSectionKeyword.connection.execute('alter table tagged_section_keywords add foreign key (otu_page_layout_section_id) references otu_page_layout_sections (id);')
    TaggedSectionKeyword.connection.execute('alter table tagged_section_keywords add foreign key (created_by_id) references users (id);')
    TaggedSectionKeyword.connection.execute('alter table tagged_section_keywords add foreign key (updated_by_id) references users (id);')
    TaggedSectionKeyword.connection.execute('alter table tagged_section_keywords add foreign key (project_id) references projects (id);')
    TaggedSectionKeyword.connection.execute('alter table tagged_section_keywords add foreign key (keyword_id) references controlled_vocabulary_terms (id);')

    TaxonDetermination.connection.execute('alter table taxon_determinations add foreign key (biological_collection_object_id) references collection_objects (id);')
    TaxonDetermination.connection.execute('alter table taxon_determinations add foreign key (otu_id) references otus (id);')
    TaxonDetermination.connection.execute('alter table taxon_determinations add foreign key (created_by_id) references users (id);')
    TaxonDetermination.connection.execute('alter table taxon_determinations add foreign key (updated_by_id) references users (id);')
    TaxonDetermination.connection.execute('alter table taxon_determinations add foreign key (project_id) references projects (id);')

    TaxonName.connection.execute('alter table taxon_names add foreign key (parent_id) references taxon_names (id);')
    TaxonName.connection.execute('alter table taxon_names add foreign key (source_id) references sources (id);')
    TaxonName.connection.execute('alter table taxon_names add foreign key (created_by_id) references users (id);')
    TaxonName.connection.execute('alter table taxon_names add foreign key (updated_by_id) references users (id);')
    TaxonName.connection.execute('alter table taxon_names add foreign key (project_id) references projects (id);')

    TaxonNameClassification.connection.execute('alter table taxon_name_classifications add foreign key (taxon_name_id) references taxon_names (id);')
    TaxonNameClassification.connection.execute('alter table taxon_name_classifications add foreign key (created_by_id) references users (id);')
    TaxonNameClassification.connection.execute('alter table taxon_name_classifications add foreign key (updated_by_id) references users (id);')
    TaxonNameClassification.connection.execute('alter table taxon_name_classifications add foreign key (project_id) references projects (id);')

    TaxonNameRelationship.connection.execute('alter table taxon_name_relationships add foreign key (subject_taxon_name_id) references taxon_names (id);')
    TaxonNameRelationship.connection.execute('alter table taxon_name_relationships add foreign key (object_taxon_name_id) references taxon_names (id);')
    TaxonNameRelationship.connection.execute('alter table taxon_name_relationships add foreign key (created_by_id) references users (id);')
    TaxonNameRelationship.connection.execute('alter table taxon_name_relationships add foreign key (updated_by_id) references users (id);')
    TaxonNameRelationship.connection.execute('alter table taxon_name_relationships add foreign key (project_id) references projects (id);')
    TaxonNameRelationship.connection.execute('alter table taxon_name_relationships add foreign key (source_id) references sources (id);')

    TypeMaterial.connection.execute('alter table type_materials add foreign key (protonym_id) references taxon_names (id);')
    TypeMaterial.connection.execute('alter table type_materials add foreign key (biological_object_id) references collection_objects (id);')
    TypeMaterial.connection.execute('alter table type_materials add foreign key (source_id) references sources (id);')
    TypeMaterial.connection.execute('alter table type_materials add foreign key (created_by_id) references users (id);')
    TypeMaterial.connection.execute('alter table type_materials add foreign key (updated_by_id) references users (id);')
    TypeMaterial.connection.execute('alter table type_materials add foreign key (project_id) references projects (id);')

    User.connection.execute('alter table users add foreign key (created_by_id) references users (id);')
    User.connection.execute('alter table users add foreign key (updated_by_id) references users (id);')

  end
end
