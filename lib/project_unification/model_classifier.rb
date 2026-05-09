# Classifies models by their uniqueness validation complexity
# to determine optimal migration strategy during project unification
#
module ProjectUnification
  class ModelClassifier
    # Fast track: Simple uniqueness on project_id only - can use bulk SQL UPDATE
    # Includes all Annotation models which don't need validation
    FAST_TRACK = %w[
      ProjectSource
      RangedLotCategory
      OtuPageLayout
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
    ].freeze

    # Medium track: Moderate complexity - need validation checks before UPDATE
    MEDIUM_TRACK = %w[
      ObservationMatrix
      ControlledVocabularyTerm
      PinboardItem
      ObservationMatrixColumn
      TaxonNameClassification
    ].freeze

    # Slow track: High complexity - require per-record validation
    SLOW_TRACK = %w[
      ImportAttribute
      InternalAttribute
      TaxonNameRelationship
      TaxonDetermination
    ].freeze

    # Special handling required - custom migration logic
    SPECIAL_HANDLING = %w[
      TaxonName
      CollectingEvent
      Image
      Document
    ].freeze

    # Cached tables - use direct SQL update without validation
    CACHED_TABLES = %w[
      CachedMap
      CachedMapItem
      CachedMapRegister
    ].freeze

    # Never migrate these
    EXCLUDED = %w[ProjectMember].freeze

    # Models that have uniqueness validations but don't explicitly scope to project_id
    # These are handled based on business logic - most can be fast-tracked
    IMPLICIT_SCOPE = %w[
      TypeMaterial
      CharacterState
      BiocurationClassification
      Tag
      OtuRelationship
      Content
      SledImage
      LoanItem
      GeneAttribute
      DerivedCollectionObject
      CitationTopic
      BiologicalAssociationsBiologicalAssociationsGraph
      OtuPageLayoutSection
    ].freeze

    # @param model_class [Class] ActiveRecord model class
    # @return [Symbol] :fast, :medium, :slow, :special, :cached, :implicit, or :excluded
    def self.track_for(model_class)
      name = model_class.name

      return :excluded if EXCLUDED.include?(name)
      return :cached if CACHED_TABLES.include?(name)
      return :special if SPECIAL_HANDLING.include?(name)
      return :fast if FAST_TRACK.include?(name)
      return :medium if MEDIUM_TRACK.include?(name)
      return :slow if SLOW_TRACK.include?(name)
      return :implicit if IMPLICIT_SCOPE.include?(name)

      # Check if table name starts with 'cached_' for dynamic cached tables
      return :cached if model_class.table_name.to_s.start_with?('cached_')

      # Default to implicit for models not explicitly categorized
      # These are typically safe to bulk update
      :implicit
    end

    # @return [Hash] Statistics about model distribution
    def self.statistics
      {
        fast_track: FAST_TRACK.length,
        medium_track: MEDIUM_TRACK.length,
        slow_track: SLOW_TRACK.length,
        special: SPECIAL_HANDLING.length,
        implicit: IMPLICIT_SCOPE.length,
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
