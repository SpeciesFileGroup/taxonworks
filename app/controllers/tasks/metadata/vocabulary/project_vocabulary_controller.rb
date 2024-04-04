class Tasks::Metadata::Vocabulary::ProjectVocabularyController < ApplicationController
  include TaskControllerConfiguration

  def data_models
    allowed= %w{
      AlternateValue
      BiologicalAssociationsGraph
      BiologicalRelationship
      BiologicalRelationshipType
      CharacterState
      Citation
      CitationTopic
      CollectingEvent
      CollectionObject
      CollectionObjectObservation
      CollectionProfile
      CommonName
      Container
      Content
      ControlledVocabularyTerm
      DataAttribute
      Depiction
      DerivedCollectionObject
      Descriptor
      Document
      Download
      Extract
      FieldOccurrence
      GeographicArea
      GeographicAreaType
      Identifier
      Image
      Label
      Language
      Lead
      Loan
      LoanItem
      Namespace
      Note
      Observation
      ObservationMatrix
      Organization
      Otu
      OtuRelationship
      Person
      PreparationType
      Protocol
      RangedLotCategory
      Repository
      Sequence
      Serial
      SerialChronology
      SledImage
      Source
      SqedDepiction
      TaxonDetermination
      TaxonName
      TaxonNameClassification
      TaxonNameRelationship
    }

    render json: allowed
  end

end
