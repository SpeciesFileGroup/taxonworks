class TaxonNameRelationship::Icn < TaxonNameRelationship
  validates_uniqueness_of :subject_taxon_name_id, scope: :type

  # left_side
  def self.valid_subject_ranks
    RANK_CLASS_NAMES_ICN
  end

  # right_side
  def self.valid_object_ranks
    RANK_CLASS_NAMES_ICN
  end

  def self.disjoint_taxon_name_relationships
    self.collect_descendants_to_s(
        TaxonNameRelationship::Iczn,
        TaxonNameRelationship::Combination)
  end

  def self.disjoint_subject_classes
    self.collect_descendants_to_s(
        TaxonNameClassification::Iczn)
  end

  def self.disjoint_object_classes
    [TaxonNameClassification::Iczn::NotEffectivelyPublished.to_s]
  end

end
