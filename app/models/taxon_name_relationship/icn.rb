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
    ICZN_TAXON_NAME_RELATIONSHIP_NAMES +
        self.collect_descendants_to_s(TaxonNameRelationship::Combination)
  end

  @@disjoint_classes = self.collect_descendants_to_s(TaxonNameClassification::Iczn)

  def self.disjoint_subject_classes
    @@disjoint_classes
  end

  def self.disjoint_object_classes
    @@disjoint_classes + [TaxonNameClassification::Icn::NotEffectivelyPublished.to_s]
  end

end
