class TaxonNameRelationship::Iczn < TaxonNameRelationship
  validates_uniqueness_of :subject_taxon_name_id, scope: :type

  # left_side
  def self.valid_subject_ranks
    FAMILY_RANK_NAMES_ICZN + GENUS_AND_SPECIES_RANK_NAMES_ICZN
  end

  # right_side
  def self.valid_object_ranks
    FAMILY_RANK_NAMES_ICZN + GENUS_AND_SPECIES_RANK_NAMES_ICZN
  end

  def self.disjoint_taxon_name_relationships
    self.collect_descendants_to_s(TaxonNameRelationship::Icn,
                                  TaxonNameRelationship::Combination)
  end

  @@disjoint_classes = self.collect_descendants_to_s(TaxonNameClassification::Icn)

  def self.disjoint_subject_classes
    @@disjoint_classes
  end

  def self.disjoint_object_classes
    @@disjoint_classes
  end


end
