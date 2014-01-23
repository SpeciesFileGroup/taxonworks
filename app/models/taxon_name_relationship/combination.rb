class TaxonNameRelationship::Combination < TaxonNameRelationship
  # Abstract class.
  validates_uniqueness_of :object_taxon_name_id, scope: :type

  def self.disjoint_taxon_name_relationships
    self.collect_descendants_to_s(
        TaxonNameRelationship::Iczn,
        TaxonNameRelationship::Icn,
        TaxonNameRelationship::OriginalCombination,
        TaxonNameRelationship::Typification) +
        [TaxonNameRelationship::SourceClassifiedAs.to_s]
  end

  @@disjoint_classes = self.collect_descendants_to_s(TaxonNameClassification)

  def self.disjoint_subject_classes
    @@disjoint_classes
  end

  def self.disjoint_object_classes
    @@disjoint_classes
  end

  def self.nomenclatural_priority
    :reverse
  end

end
