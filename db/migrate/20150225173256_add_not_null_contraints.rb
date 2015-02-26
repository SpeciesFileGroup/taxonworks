class AddNotNullContraints < ActiveRecord::Migration
  def change
      # AlternateValue
       AlternateValue.connection.execute('alter table alternate_values alter value set not null;')
       AlternateValue.connection.execute('alter table alternate_values alter type set not null;')
       AlternateValue.connection.execute('alter table alternate_values alter created_at set not null;')
       AlternateValue.connection.execute('alter table alternate_values alter updated_at set not null;')
       AlternateValue.connection.execute('alter table alternate_values alter created_by_id set not null;')
       AlternateValue.connection.execute('alter table alternate_values alter updated_by_id set not null;')
       AlternateValue.connection.execute('alter table alternate_values alter alternate_value_object_id set not null;')
       AlternateValue.connection.execute('alter table alternate_values alter alternate_value_object_type set not null;')

      # AssertedDistribution
       AssertedDistribution.connection.execute('alter table asserted_distributions alter otu_id set not null;')
       AssertedDistribution.connection.execute('alter table asserted_distributions alter geographic_area_id set not null;')
       AssertedDistribution.connection.execute('alter table asserted_distributions alter source_id set not null;')
       AssertedDistribution.connection.execute('alter table asserted_distributions alter project_id set not null;')
       AssertedDistribution.connection.execute('alter table asserted_distributions alter created_by_id set not null;')
       AssertedDistribution.connection.execute('alter table asserted_distributions alter updated_by_id set not null;')
       AssertedDistribution.connection.execute('alter table asserted_distributions alter created_at set not null;')
       AssertedDistribution.connection.execute('alter table asserted_distributions alter updated_at set not null;')

      # BiocurationClassification
       BiocurationClassification.connection.execute('alter table biocuration_classifications alter biocuration_class_id set not null;')
       BiocurationClassification.connection.execute('alter table biocuration_classifications alter biological_collection_object_id set not null;')
       BiocurationClassification.connection.execute('alter table biocuration_classifications alter position set not null;')
       BiocurationClassification.connection.execute('alter table biocuration_classifications alter created_at set not null;')
       BiocurationClassification.connection.execute('alter table biocuration_classifications alter updated_at set not null;')
       BiocurationClassification.connection.execute('alter table biocuration_classifications alter created_by_id set not null;')
       BiocurationClassification.connection.execute('alter table biocuration_classifications alter updated_by_id set not null;')
       BiocurationClassification.connection.execute('alter table biocuration_classifications alter project_id set not null;')

      # BiologicalAssociation
       BiologicalAssociation.connection.execute('alter table biological_associations alter biological_relationship_id set not null;')
       BiologicalAssociation.connection.execute('alter table biological_associations alter biological_association_subject_id set not null;')
       BiologicalAssociation.connection.execute('alter table biological_associations alter biological_association_subject_type set not null;')
       BiologicalAssociation.connection.execute('alter table biological_associations alter biological_association_object_id set not null;')
       BiologicalAssociation.connection.execute('alter table biological_associations alter biological_association_object_type set not null;')
       BiologicalAssociation.connection.execute('alter table biological_associations alter created_at set not null;')
       BiologicalAssociation.connection.execute('alter table biological_associations alter updated_at set not null;')
       BiologicalAssociation.connection.execute('alter table biological_associations alter created_by_id set not null;')
       BiologicalAssociation.connection.execute('alter table biological_associations alter updated_by_id set not null;')
       BiologicalAssociation.connection.execute('alter table biological_associations alter project_id set not null;')

      # BiologicalAssociationsBiologicalAssociationsGraph
       BiologicalAssociationsBiologicalAssociationsGraph.connection.execute('alter table biological_associations_biological_associations_graphs alter biological_associations_graph_id set not null;')
       BiologicalAssociationsBiologicalAssociationsGraph.connection.execute('alter table biological_associations_biological_associations_graphs alter biological_association_id set not null;')
       BiologicalAssociationsBiologicalAssociationsGraph.connection.execute('alter table biological_associations_biological_associations_graphs alter created_at set not null;')
       BiologicalAssociationsBiologicalAssociationsGraph.connection.execute('alter table biological_associations_biological_associations_graphs alter updated_at set not null;')
       BiologicalAssociationsBiologicalAssociationsGraph.connection.execute('alter table biological_associations_biological_associations_graphs alter created_by_id set not null;')
       BiologicalAssociationsBiologicalAssociationsGraph.connection.execute('alter table biological_associations_biological_associations_graphs alter updated_by_id set not null;')
       BiologicalAssociationsBiologicalAssociationsGraph.connection.execute('alter table biological_associations_biological_associations_graphs alter project_id set not null;')

      # BiologicalAssociationsGraph
       BiologicalAssociationsGraph.connection.execute('alter table biological_associations_graphs alter created_at set not null;')
       BiologicalAssociationsGraph.connection.execute('alter table biological_associations_graphs alter updated_at set not null;')
       BiologicalAssociationsGraph.connection.execute('alter table biological_associations_graphs alter created_by_id set not null;')
       BiologicalAssociationsGraph.connection.execute('alter table biological_associations_graphs alter updated_by_id set not null;')
       BiologicalAssociationsGraph.connection.execute('alter table biological_associations_graphs alter project_id set not null;')

      # BiologicalRelationship
       BiologicalRelationship.connection.execute('alter table biological_relationships alter name set not null;')
       BiologicalRelationship.connection.execute('alter table biological_relationships alter created_at set not null;')
       BiologicalRelationship.connection.execute('alter table biological_relationships alter updated_at set not null;')
       BiologicalRelationship.connection.execute('alter table biological_relationships alter created_by_id set not null;')
       BiologicalRelationship.connection.execute('alter table biological_relationships alter updated_by_id set not null;')
       BiologicalRelationship.connection.execute('alter table biological_relationships alter project_id set not null;')

      # BiologicalRelationshipType
       BiologicalRelationshipType.connection.execute('alter table biological_relationship_types alter type set not null;')
       BiologicalRelationshipType.connection.execute('alter table biological_relationship_types alter biological_property_id set not null;')
       BiologicalRelationshipType.connection.execute('alter table biological_relationship_types alter biological_relationship_id set not null;')
       BiologicalRelationshipType.connection.execute('alter table biological_relationship_types alter created_at set not null;')
       BiologicalRelationshipType.connection.execute('alter table biological_relationship_types alter updated_at set not null;')
       BiologicalRelationshipType.connection.execute('alter table biological_relationship_types alter created_by_id set not null;')
       BiologicalRelationshipType.connection.execute('alter table biological_relationship_types alter updated_by_id set not null;')
       BiologicalRelationshipType.connection.execute('alter table biological_relationship_types alter project_id set not null;')

      # Citation
       Citation.connection.execute('alter table citations alter source_id set not null;')
       Citation.connection.execute('alter table citations alter created_at set not null;')
       Citation.connection.execute('alter table citations alter updated_at set not null;')
       Citation.connection.execute('alter table citations alter created_by_id set not null;')
       Citation.connection.execute('alter table citations alter updated_by_id set not null;')
       Citation.connection.execute('alter table citations alter project_id set not null;')

      # CitationTopic
       CitationTopic.connection.execute('alter table citation_topics alter topic_id set not null;')
       CitationTopic.connection.execute('alter table citation_topics alter citation_id set not null;')
       CitationTopic.connection.execute('alter table citation_topics alter created_at set not null;')
       CitationTopic.connection.execute('alter table citation_topics alter updated_at set not null;')
       CitationTopic.connection.execute('alter table citation_topics alter created_by_id set not null;')
       CitationTopic.connection.execute('alter table citation_topics alter updated_by_id set not null;')
       CitationTopic.connection.execute('alter table citation_topics alter project_id set not null;')

      # CollectingEvent
       CollectingEvent.connection.execute('alter table collecting_events alter created_at set not null;')
       CollectingEvent.connection.execute('alter table collecting_events alter updated_at set not null;')
       CollectingEvent.connection.execute('alter table collecting_events alter created_by_id set not null;')
       CollectingEvent.connection.execute('alter table collecting_events alter updated_by_id set not null;')
       CollectingEvent.connection.execute('alter table collecting_events alter project_id set not null;')

      # CollectionObject
       CollectionObject.connection.execute('alter table collection_objects alter type set not null;')
       CollectionObject.connection.execute('alter table collection_objects alter created_at set not null;')
       CollectionObject.connection.execute('alter table collection_objects alter updated_at set not null;')
       CollectionObject.connection.execute('alter table collection_objects alter created_by_id set not null;')
       CollectionObject.connection.execute('alter table collection_objects alter updated_by_id set not null;')
       CollectionObject.connection.execute('alter table collection_objects alter project_id set not null;')

      # CollectionProfile
       CollectionProfile.connection.execute('alter table collection_profiles alter created_by_id set not null;')
       CollectionProfile.connection.execute('alter table collection_profiles alter updated_by_id set not null;')
       CollectionProfile.connection.execute('alter table collection_profiles alter project_id set not null;')
       CollectionProfile.connection.execute('alter table collection_profiles alter created_at set not null;')
       CollectionProfile.connection.execute('alter table collection_profiles alter updated_at set not null;')

      # Container
       Container.connection.execute('alter table containers alter created_at set not null;')
       Container.connection.execute('alter table containers alter updated_at set not null;')
       Container.connection.execute('alter table containers alter lft set not null;')
       Container.connection.execute('alter table containers alter rgt set not null;')
       Container.connection.execute('alter table containers alter type set not null;')
       Container.connection.execute('alter table containers alter created_by_id set not null;')
       Container.connection.execute('alter table containers alter updated_by_id set not null;')
       Container.connection.execute('alter table containers alter project_id set not null;')

      # ContainerItem
       ContainerItem.connection.execute('alter table container_items alter container_id set not null;')
       ContainerItem.connection.execute('alter table container_items alter position set not null;')
       ContainerItem.connection.execute('alter table container_items alter created_at set not null;')
       ContainerItem.connection.execute('alter table container_items alter updated_at set not null;')
       ContainerItem.connection.execute('alter table container_items alter created_by_id set not null;')
       ContainerItem.connection.execute('alter table container_items alter updated_by_id set not null;')
       ContainerItem.connection.execute('alter table container_items alter project_id set not null;')

      # ContainerLabel
       ContainerLabel.connection.execute('alter table container_labels alter label set not null;')
       ContainerLabel.connection.execute('alter table container_labels alter position set not null;')
       ContainerLabel.connection.execute('alter table container_labels alter created_by_id set not null;')
       ContainerLabel.connection.execute('alter table container_labels alter updated_by_id set not null;')
       ContainerLabel.connection.execute('alter table container_labels alter project_id set not null;')
       ContainerLabel.connection.execute('alter table container_labels alter created_at set not null;')
       ContainerLabel.connection.execute('alter table container_labels alter updated_at set not null;')
       ContainerLabel.connection.execute('alter table container_labels alter container_id set not null;')

      # Content
       Content.connection.execute('alter table contents alter text set not null;')
       Content.connection.execute('alter table contents alter otu_id set not null;')
       Content.connection.execute('alter table contents alter topic_id set not null;')
       Content.connection.execute('alter table contents alter created_at set not null;')
       Content.connection.execute('alter table contents alter updated_at set not null;')
       Content.connection.execute('alter table contents alter created_by_id set not null;')
       Content.connection.execute('alter table contents alter updated_by_id set not null;')
       Content.connection.execute('alter table contents alter project_id set not null;')

      # ControlledVocabularyTerm
       ControlledVocabularyTerm.connection.execute('alter table controlled_vocabulary_terms alter type set not null;')
       ControlledVocabularyTerm.connection.execute('alter table controlled_vocabulary_terms alter name set not null;')
       ControlledVocabularyTerm.connection.execute('alter table controlled_vocabulary_terms alter definition set not null;')
       ControlledVocabularyTerm.connection.execute('alter table controlled_vocabulary_terms alter created_at set not null;')
       ControlledVocabularyTerm.connection.execute('alter table controlled_vocabulary_terms alter updated_at set not null;')
       ControlledVocabularyTerm.connection.execute('alter table controlled_vocabulary_terms alter created_by_id set not null;')
       ControlledVocabularyTerm.connection.execute('alter table controlled_vocabulary_terms alter updated_by_id set not null;')
       ControlledVocabularyTerm.connection.execute('alter table controlled_vocabulary_terms alter project_id set not null;')

      # DataAttribute
       DataAttribute.connection.execute('alter table data_attributes alter type set not null;')
       DataAttribute.connection.execute('alter table data_attributes alter value set not null;')
       DataAttribute.connection.execute('alter table data_attributes alter created_by_id set not null;')
       DataAttribute.connection.execute('alter table data_attributes alter updated_by_id set not null;')
       DataAttribute.connection.execute('alter table data_attributes alter created_at set not null;')
       DataAttribute.connection.execute('alter table data_attributes alter updated_at set not null;')

      # GeographicArea
       GeographicArea.connection.execute('alter table geographic_areas alter name set not null;')
       GeographicArea.connection.execute('alter table geographic_areas alter created_at set not null;')
       GeographicArea.connection.execute('alter table geographic_areas alter updated_at set not null;')
       GeographicArea.connection.execute('alter table geographic_areas alter rgt set not null;')
       GeographicArea.connection.execute('alter table geographic_areas alter lft set not null;')
       GeographicArea.connection.execute('alter table geographic_areas alter data_origin set not null;')
       GeographicArea.connection.execute('alter table geographic_areas alter created_by_id set not null;')
       GeographicArea.connection.execute('alter table geographic_areas alter updated_by_id set not null;')

      # GeographicAreaType
       GeographicAreaType.connection.execute('alter table geographic_area_types alter name set not null;')
       GeographicAreaType.connection.execute('alter table geographic_area_types alter created_at set not null;')
       GeographicAreaType.connection.execute('alter table geographic_area_types alter updated_at set not null;')
       GeographicAreaType.connection.execute('alter table geographic_area_types alter created_by_id set not null;')
       GeographicAreaType.connection.execute('alter table geographic_area_types alter updated_by_id set not null;')

      # GeographicAreasGeographicItem
       GeographicAreasGeographicItem.connection.execute('alter table geographic_areas_geographic_items alter geographic_area_id set not null;')
       GeographicAreasGeographicItem.connection.execute('alter table geographic_areas_geographic_items alter created_at set not null;')
       GeographicAreasGeographicItem.connection.execute('alter table geographic_areas_geographic_items alter updated_at set not null;')

      # GeographicItem
       GeographicItem.connection.execute('alter table geographic_items alter created_at set not null;')
       GeographicItem.connection.execute('alter table geographic_items alter updated_at set not null;')
       GeographicItem.connection.execute('alter table geographic_items alter created_by_id set not null;')
       GeographicItem.connection.execute('alter table geographic_items alter updated_by_id set not null;')
       GeographicItem.connection.execute('alter table geographic_items alter type set not null;')

      # Georeference
       Georeference.connection.execute('alter table georeferences alter geographic_item_id set not null;')
       Georeference.connection.execute('alter table georeferences alter collecting_event_id set not null;')
       Georeference.connection.execute('alter table georeferences alter type set not null;')
       Georeference.connection.execute('alter table georeferences alter position set not null;')
       Georeference.connection.execute('alter table georeferences alter created_at set not null;')
       Georeference.connection.execute('alter table georeferences alter updated_at set not null;')
       Georeference.connection.execute('alter table georeferences alter is_public set not null;')
       Georeference.connection.execute('alter table georeferences alter created_by_id set not null;')
       Georeference.connection.execute('alter table georeferences alter updated_by_id set not null;')
       Georeference.connection.execute('alter table georeferences alter project_id set not null;')

      # Identifier
       Identifier.connection.execute('alter table identifiers alter identifier set not null;')
       Identifier.connection.execute('alter table identifiers alter type set not null;')
       Identifier.connection.execute('alter table identifiers alter created_at set not null;')
       Identifier.connection.execute('alter table identifiers alter updated_at set not null;')
       Identifier.connection.execute('alter table identifiers alter created_by_id set not null;')
       Identifier.connection.execute('alter table identifiers alter updated_by_id set not null;')

      # Image
       Image.connection.execute('alter table images alter created_by_id set not null;')
       Image.connection.execute('alter table images alter project_id set not null;')
       Image.connection.execute('alter table images alter created_at set not null;')
       Image.connection.execute('alter table images alter updated_at set not null;')
       Image.connection.execute('alter table images alter updated_by_id set not null;')

      # Import

      # Language
       Language.connection.execute('alter table languages alter created_at set not null;')
       Language.connection.execute('alter table languages alter updated_at set not null;')
       Language.connection.execute('alter table languages alter created_by_id set not null;')
       Language.connection.execute('alter table languages alter updated_by_id set not null;')

      # Loan
       Loan.connection.execute('alter table loans alter created_by_id set not null;')
       Loan.connection.execute('alter table loans alter updated_by_id set not null;')
       Loan.connection.execute('alter table loans alter project_id set not null;')
       Loan.connection.execute('alter table loans alter created_at set not null;')
       Loan.connection.execute('alter table loans alter updated_at set not null;')

      # LoanItem
       LoanItem.connection.execute('alter table loan_items alter loan_id set not null;')
       LoanItem.connection.execute('alter table loan_items alter position set not null;')
       LoanItem.connection.execute('alter table loan_items alter created_by_id set not null;')
       LoanItem.connection.execute('alter table loan_items alter updated_by_id set not null;')
       LoanItem.connection.execute('alter table loan_items alter project_id set not null;')
       LoanItem.connection.execute('alter table loan_items alter created_at set not null;')
       LoanItem.connection.execute('alter table loan_items alter updated_at set not null;')

      # Namespace
       Namespace.connection.execute('alter table namespaces alter name set not null;')
       Namespace.connection.execute('alter table namespaces alter short_name set not null;')
       Namespace.connection.execute('alter table namespaces alter created_at set not null;')
       Namespace.connection.execute('alter table namespaces alter updated_at set not null;')
       Namespace.connection.execute('alter table namespaces alter created_by_id set not null;')
       Namespace.connection.execute('alter table namespaces alter updated_by_id set not null;')

      # Note
       Note.connection.execute('alter table notes alter text set not null;')
       Note.connection.execute('alter table notes alter created_at set not null;')
       Note.connection.execute('alter table notes alter updated_at set not null;')
       Note.connection.execute('alter table notes alter created_by_id set not null;')
       Note.connection.execute('alter table notes alter updated_by_id set not null;')
       Note.connection.execute('alter table notes alter project_id set not null;')

      # Otu
       Otu.connection.execute('alter table otus alter created_at set not null;')
       Otu.connection.execute('alter table otus alter updated_at set not null;')
       Otu.connection.execute('alter table otus alter created_by_id set not null;')
       Otu.connection.execute('alter table otus alter updated_by_id set not null;')
       Otu.connection.execute('alter table otus alter project_id set not null;')

      # OtuPageLayout
       OtuPageLayout.connection.execute('alter table otu_page_layouts alter name set not null;')
       OtuPageLayout.connection.execute('alter table otu_page_layouts alter created_by_id set not null;')
       OtuPageLayout.connection.execute('alter table otu_page_layouts alter updated_by_id set not null;')
       OtuPageLayout.connection.execute('alter table otu_page_layouts alter project_id set not null;')
       OtuPageLayout.connection.execute('alter table otu_page_layouts alter created_at set not null;')
       OtuPageLayout.connection.execute('alter table otu_page_layouts alter updated_at set not null;')

      # OtuPageLayoutSection
       OtuPageLayoutSection.connection.execute('alter table otu_page_layout_sections alter otu_page_layout_id set not null;')
       OtuPageLayoutSection.connection.execute('alter table otu_page_layout_sections alter type set not null;')
       OtuPageLayoutSection.connection.execute('alter table otu_page_layout_sections alter position set not null;')
       OtuPageLayoutSection.connection.execute('alter table otu_page_layout_sections alter created_by_id set not null;')
       OtuPageLayoutSection.connection.execute('alter table otu_page_layout_sections alter updated_by_id set not null;')
       OtuPageLayoutSection.connection.execute('alter table otu_page_layout_sections alter project_id set not null;')
       OtuPageLayoutSection.connection.execute('alter table otu_page_layout_sections alter created_at set not null;')
       OtuPageLayoutSection.connection.execute('alter table otu_page_layout_sections alter updated_at set not null;')

      # PaperTrail::Version
       PaperTrail::Version.connection.execute('alter table versions alter created_at set not null;')

      # Person
       Person.connection.execute('alter table people alter type set not null;')
       Person.connection.execute('alter table people alter last_name set not null;')
       Person.connection.execute('alter table people alter created_at set not null;')
       Person.connection.execute('alter table people alter updated_at set not null;')
       Person.connection.execute('alter table people alter created_by_id set not null;')
       Person.connection.execute('alter table people alter updated_by_id set not null;')

      # PinboardItem
       PinboardItem.connection.execute('alter table pinboard_items alter user_id set not null;')
       PinboardItem.connection.execute('alter table pinboard_items alter project_id set not null;')
       PinboardItem.connection.execute('alter table pinboard_items alter position set not null;')
       PinboardItem.connection.execute('alter table pinboard_items alter created_by_id set not null;')
       PinboardItem.connection.execute('alter table pinboard_items alter updated_by_id set not null;')
       PinboardItem.connection.execute('alter table pinboard_items alter created_at set not null;')
       PinboardItem.connection.execute('alter table pinboard_items alter updated_at set not null;')

      # PreparationType
       PreparationType.connection.execute('alter table preparation_types alter name set not null;')
       PreparationType.connection.execute('alter table preparation_types alter created_at set not null;')
       PreparationType.connection.execute('alter table preparation_types alter updated_at set not null;')
       PreparationType.connection.execute('alter table preparation_types alter created_by_id set not null;')
       PreparationType.connection.execute('alter table preparation_types alter updated_by_id set not null;')
       PreparationType.connection.execute('alter table preparation_types alter definition set not null;')

      # Project
       Project.connection.execute('alter table projects alter name set not null;')
       Project.connection.execute('alter table projects alter created_at set not null;')
       Project.connection.execute('alter table projects alter updated_at set not null;')
       Project.connection.execute('alter table projects alter created_by_id set not null;')
       Project.connection.execute('alter table projects alter updated_by_id set not null;')
       Project.connection.execute('alter table projects alter workbench_settings set not null;')

      # ProjectMember
       ProjectMember.connection.execute('alter table project_members alter project_id set not null;')
       ProjectMember.connection.execute('alter table project_members alter user_id set not null;')
       ProjectMember.connection.execute('alter table project_members alter created_at set not null;')
       ProjectMember.connection.execute('alter table project_members alter updated_at set not null;')
       ProjectMember.connection.execute('alter table project_members alter created_by_id set not null;')
       ProjectMember.connection.execute('alter table project_members alter updated_by_id set not null;')

      # ProjectSource
       ProjectSource.connection.execute('alter table project_sources alter source_id set not null;')
       ProjectSource.connection.execute('alter table project_sources alter created_by_id set not null;')
       ProjectSource.connection.execute('alter table project_sources alter updated_by_id set not null;')
       ProjectSource.connection.execute('alter table project_sources alter created_at set not null;')
       ProjectSource.connection.execute('alter table project_sources alter updated_at set not null;')

      # PublicContent
       PublicContent.connection.execute('alter table public_contents alter otu_id set not null;')
       PublicContent.connection.execute('alter table public_contents alter topic_id set not null;')
       PublicContent.connection.execute('alter table public_contents alter text set not null;')
       PublicContent.connection.execute('alter table public_contents alter project_id set not null;')
       PublicContent.connection.execute('alter table public_contents alter created_by_id set not null;')
       PublicContent.connection.execute('alter table public_contents alter updated_by_id set not null;')
       PublicContent.connection.execute('alter table public_contents alter created_at set not null;')
       PublicContent.connection.execute('alter table public_contents alter updated_at set not null;')
       PublicContent.connection.execute('alter table public_contents alter content_id set not null;')

      # RangedLotCategory
       RangedLotCategory.connection.execute('alter table ranged_lot_categories alter name set not null;')
       RangedLotCategory.connection.execute('alter table ranged_lot_categories alter minimum_value set not null;')
       RangedLotCategory.connection.execute('alter table ranged_lot_categories alter created_at set not null;')
       RangedLotCategory.connection.execute('alter table ranged_lot_categories alter updated_at set not null;')
       RangedLotCategory.connection.execute('alter table ranged_lot_categories alter created_by_id set not null;')
       RangedLotCategory.connection.execute('alter table ranged_lot_categories alter updated_by_id set not null;')
       RangedLotCategory.connection.execute('alter table ranged_lot_categories alter project_id set not null;')

      # Repository
       Repository.connection.execute('alter table repositories alter name set not null;')
       Repository.connection.execute('alter table repositories alter created_at set not null;')
       Repository.connection.execute('alter table repositories alter updated_at set not null;')
       Repository.connection.execute('alter table repositories alter created_by_id set not null;')
       Repository.connection.execute('alter table repositories alter updated_by_id set not null;')

      # Role
       Role.connection.execute('alter table roles alter person_id set not null;')
       Role.connection.execute('alter table roles alter type set not null;')
       Role.connection.execute('alter table roles alter position set not null;')
       Role.connection.execute('alter table roles alter created_at set not null;')
       Role.connection.execute('alter table roles alter updated_at set not null;')
       Role.connection.execute('alter table roles alter created_by_id set not null;')
       Role.connection.execute('alter table roles alter updated_by_id set not null;')

      # Serial
       Serial.connection.execute('alter table serials alter created_by_id set not null;')
       Serial.connection.execute('alter table serials alter updated_by_id set not null;')
       Serial.connection.execute('alter table serials alter created_at set not null;')
       Serial.connection.execute('alter table serials alter updated_at set not null;')
       Serial.connection.execute('alter table serials alter name set not null;')

      # SerialChronology
       SerialChronology.connection.execute('alter table serial_chronologies alter preceding_serial_id set not null;')
       SerialChronology.connection.execute('alter table serial_chronologies alter succeeding_serial_id set not null;')
       SerialChronology.connection.execute('alter table serial_chronologies alter created_by_id set not null;')
       SerialChronology.connection.execute('alter table serial_chronologies alter created_at set not null;')
       SerialChronology.connection.execute('alter table serial_chronologies alter updated_at set not null;')
       SerialChronology.connection.execute('alter table serial_chronologies alter updated_by_id set not null;')
       SerialChronology.connection.execute('alter table serial_chronologies alter type set not null;')

      # Source
       Source.connection.execute('alter table sources alter type set not null;')
       Source.connection.execute('alter table sources alter created_at set not null;')
       Source.connection.execute('alter table sources alter updated_at set not null;')
       Source.connection.execute('alter table sources alter created_by_id set not null;')
       Source.connection.execute('alter table sources alter updated_by_id set not null;')

      # Tag
       Tag.connection.execute('alter table tags alter keyword_id set not null;')
       Tag.connection.execute('alter table tags alter created_at set not null;')
       Tag.connection.execute('alter table tags alter updated_at set not null;')
       Tag.connection.execute('alter table tags alter created_by_id set not null;')
       Tag.connection.execute('alter table tags alter updated_by_id set not null;')
       Tag.connection.execute('alter table tags alter project_id set not null;')
       Tag.connection.execute('alter table tags alter position set not null;')

      # TaggedSectionKeyword
       TaggedSectionKeyword.connection.execute('alter table tagged_section_keywords alter otu_page_layout_section_id set not null;')
       TaggedSectionKeyword.connection.execute('alter table tagged_section_keywords alter position set not null;')
       TaggedSectionKeyword.connection.execute('alter table tagged_section_keywords alter created_by_id set not null;')
       TaggedSectionKeyword.connection.execute('alter table tagged_section_keywords alter updated_by_id set not null;')
       TaggedSectionKeyword.connection.execute('alter table tagged_section_keywords alter project_id set not null;')
       TaggedSectionKeyword.connection.execute('alter table tagged_section_keywords alter created_at set not null;')
       TaggedSectionKeyword.connection.execute('alter table tagged_section_keywords alter updated_at set not null;')
       TaggedSectionKeyword.connection.execute('alter table tagged_section_keywords alter keyword_id set not null;')

      # TaxonDetermination
       TaxonDetermination.connection.execute('alter table taxon_determinations alter biological_collection_object_id set not null;')
       TaxonDetermination.connection.execute('alter table taxon_determinations alter otu_id set not null;')
       TaxonDetermination.connection.execute('alter table taxon_determinations alter position set not null;')
       TaxonDetermination.connection.execute('alter table taxon_determinations alter created_at set not null;')
       TaxonDetermination.connection.execute('alter table taxon_determinations alter updated_at set not null;')
       TaxonDetermination.connection.execute('alter table taxon_determinations alter created_by_id set not null;')
       TaxonDetermination.connection.execute('alter table taxon_determinations alter updated_by_id set not null;')
       TaxonDetermination.connection.execute('alter table taxon_determinations alter project_id set not null;')

      # TaxonName
       TaxonName.connection.execute('alter table taxon_names alter lft set not null;')
       TaxonName.connection.execute('alter table taxon_names alter rgt set not null;')
       TaxonName.connection.execute('alter table taxon_names alter created_at set not null;')
       TaxonName.connection.execute('alter table taxon_names alter updated_at set not null;')
       TaxonName.connection.execute('alter table taxon_names alter type set not null;')
       TaxonName.connection.execute('alter table taxon_names alter created_by_id set not null;')
       TaxonName.connection.execute('alter table taxon_names alter updated_by_id set not null;')
       TaxonName.connection.execute('alter table taxon_names alter project_id set not null;')

      # TaxonNameClassification
       TaxonNameClassification.connection.execute('alter table taxon_name_classifications alter taxon_name_id set not null;')
       TaxonNameClassification.connection.execute('alter table taxon_name_classifications alter type set not null;')
       TaxonNameClassification.connection.execute('alter table taxon_name_classifications alter created_at set not null;')
       TaxonNameClassification.connection.execute('alter table taxon_name_classifications alter updated_at set not null;')
       TaxonNameClassification.connection.execute('alter table taxon_name_classifications alter created_by_id set not null;')
       TaxonNameClassification.connection.execute('alter table taxon_name_classifications alter updated_by_id set not null;')
       TaxonNameClassification.connection.execute('alter table taxon_name_classifications alter project_id set not null;')

      # TaxonNameRelationship
       TaxonNameRelationship.connection.execute('alter table taxon_name_relationships alter created_at set not null;')
       TaxonNameRelationship.connection.execute('alter table taxon_name_relationships alter updated_at set not null;')
       TaxonNameRelationship.connection.execute('alter table taxon_name_relationships alter created_by_id set not null;')
       TaxonNameRelationship.connection.execute('alter table taxon_name_relationships alter updated_by_id set not null;')
       TaxonNameRelationship.connection.execute('alter table taxon_name_relationships alter project_id set not null;')

      # TypeMaterial
       TypeMaterial.connection.execute('alter table type_materials alter protonym_id set not null;')
       TypeMaterial.connection.execute('alter table type_materials alter biological_object_id set not null;')
       TypeMaterial.connection.execute('alter table type_materials alter type_type set not null;')
       TypeMaterial.connection.execute('alter table type_materials alter created_by_id set not null;')
       TypeMaterial.connection.execute('alter table type_materials alter updated_by_id set not null;')
       TypeMaterial.connection.execute('alter table type_materials alter project_id set not null;')
       TypeMaterial.connection.execute('alter table type_materials alter created_at set not null;')
       TypeMaterial.connection.execute('alter table type_materials alter updated_at set not null;')

      # User
       User.connection.execute('alter table users alter email set not null;')
       User.connection.execute('alter table users alter password_digest set not null;')
       User.connection.execute('alter table users alter created_at set not null;')
       User.connection.execute('alter table users alter updated_at set not null;')
       User.connection.execute('alter table users alter name set not null;')
  end
end
