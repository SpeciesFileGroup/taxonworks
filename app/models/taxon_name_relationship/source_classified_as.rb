class TaxonNameRelationship::SourceClassifiedAs < TaxonNameRelationship

  validates_uniqueness_of :object_taxon_name_id, scope: :type

  # left_side
  def self.valid_subject_ranks
    FAMILY_AND_ABOVE_RANK_NAMES
  end

  # right_side
  def self.valid_object_ranks
    RANKS #  RANK_CLASS_NAMES
  end

  def self.disjoint_subject_classes
    self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Unavailable,
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
        TaxonNameClassification::Icn::NotEffectivelyPublished)
  end

  def self.subject_relationship_name
    'as classified for'
  end

  def self.object_relationship_name
    'classified as'
  end

  def self.assignment_method
    #family.as_source_classified > [Genus]
    :as_source_classified
  end

  def self.inverse_assignment_method
    #genus.source_classified_as = Family
    :source_classified_as
  end

  def self.assignable
    true
  end

  def self.nomenclatural_priority
    :reverse
  end

end
