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

  def self.disjoint_subject_classes
    ICZN_TAXON_NAME_CLASS_NAMES
  end

  def self.disjoint_object_classes
    ICZN_TAXON_NAME_CLASS_NAMES +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icn::NotEffectivelyPublished,
            TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
            TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate)
  end

end
