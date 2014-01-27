class TaxonNameRelationship::SourceClassifiedAs < TaxonNameRelationship

  validates_uniqueness_of :object_taxon_name_id, scope: :type

  # left_side
  def self.valid_subject_ranks
    FAMILY_AND_ABOVE_RANK_NAMES
  end

  # right_side
  def self.valid_object_ranks
    RANK_CLASS_NAMES
  end

  def self.disjoint_taxon_name_relationships
    self.collect_descendants_to_s(TaxonNameRelationship::Combination)
  end

  def self.disjoint_subject_classes
    self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Unavailable,
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
        TaxonNameClassification::Icn::NotEffectivelyPublished)
  end

  def self.subject_relationship_name
    'classified as'
  end

  def self.assignment_method
    :source_classified_as
  end

  def self.assignable
    true
  end

end
