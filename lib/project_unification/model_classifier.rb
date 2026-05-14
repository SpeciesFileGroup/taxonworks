# Classifies models by their migration strategy during project unification.
#
# Fast track: bulk SQL UPDATE — no per-record validation needed.
# Slow track: per-record valid? check to detect uniqueness conflicts against the
#   target project, then save!(validate: false) on success.
#
module ProjectUnification
  class ModelClassifier
    # Bulk SQL UPDATE — no per-record validation. Safe only when the model has
    # no project-scoped uniqueness validators, OR when every such validator's
    # scope includes a FK to a project-specific model (making cross-project
    # collisions impossible). See model_classifier_spec.rb for the tripwire.
    FAST_TRACK = %w[
      Container
      Tag
      Note
      Citation
      DataAttribute
      Identifier
      AlternateValue
      Confidence
      Depiction
      Documentation
      Attribution
      Conveyance
      ProtocolRelationship
      DwcOccurrence
      BiologicalAssociationIndex
      TaxonNameClassification
      TaxonNameRelationship
      PinboardItem
      ImportAttribute
      InternalAttribute
      News
      Observation
      TaggedSectionKeyword
      Role
      Label
      Protocol
      SqedDepiction
      CollectionObjectObservation
      AnatomicalPart
      AssertedDistribution
      BiologicalRelationshipType
      BiologicalAssociation
      BiologicalRelationship
      BiologicalAssociationsGraph
      CollectionProfile
      ContainerItem
      PublicContent
      Gazetteer
      GazetteerImport
      Georeference
      Lead
      LeadItem
      Loan
      Sound
      CommonName
      OriginRelationship
      Sequence
      SequenceRelationship
      Extract
      ObservationMatrixColumnItem
      ObservationMatrixRow
      ObservationMatrixRowItem
      FieldOccurrence
      CollectionObject
      Otu
      Descriptor
      Download
      DatasetRecordField
      DatasetRecord
      OtuPageLayoutSection
      TaxonDetermination
    ].freeze

    # Per-record validation required to detect uniqueness conflicts against
    # target. Conflicts are reported to the user and the unify fails — the user
    # must resolve (e.g. rename) before retrying.
    SLOW_TRACK = %w[
      ObservationMatrix
      ObservationMatrixColumn
      TypeMaterial
      CharacterState
      BiocurationClassification
      OtuRelationship
      Content
      SledImage
      LoanItem
      GeneAttribute
      DerivedCollectionObject
      CitationTopic
      BiologicalAssociationsBiologicalAssociationsGraph
      ImportDataset
    ].freeze

    # Special handling required - custom migration logic.
    SPECIAL_HANDLING = %w[
      TaxonName
      CollectingEvent
      ProjectSource
      RangedLotCategory
      OtuPageLayout
      Image
      Document
      ControlledVocabularyTerm
    ].freeze

    # Cached tables - use direct SQL update without validation.
    CACHED_TABLES = %w[
      CachedMap
      CachedMapItem
      CachedMapRegister
    ].freeze

    # Never migrate these.
    EXCLUDED = %w[ProjectMember].freeze

    # @param model_class [Class] ActiveRecord model class
    # @return [Symbol] :fast, :slow, :special, :cached, or :excluded
    def self.track_for(model_class)
      name = model_class.name

      return :excluded if EXCLUDED.include?(name)
      return :cached if CACHED_TABLES.include?(name)
      return :cached if model_class.table_name.to_s.start_with?('cached_')
      return :special if SPECIAL_HANDLING.include?(name)
      return :fast if FAST_TRACK.include?(name)
      return :slow if SLOW_TRACK.include?(name)

      raise ArgumentError, "#{name} is not classified in ModelClassifier — add it to the appropriate track"
    end

    # @return [Hash] Statistics about model distribution
    def self.statistics
      {
        fast_track: FAST_TRACK.length,
        slow_track: SLOW_TRACK.length,
        special: SPECIAL_HANDLING.length,
        excluded: EXCLUDED.length
      }
    end

    # @param model_class [Class]
    # @return [Boolean] true if model should be migrated
    def self.should_migrate?(model_class)
      track_for(model_class) != :excluded
    end
  end
end
