class TaxonNameRelationship::Combination < TaxonNameRelationship
  # Abstract class.
  validates_uniqueness_of :object_taxon_name_id, scope: :type

  def self.disjoint_taxon_name_relationships
    self.collect_descendants_to_s(
        TaxonNameRelationship::Iczn,
        TaxonNameRelationship::Icn,
        TaxonNameRelationship::OriginalCombination,
        TaxonNameRelationship::Typification) + self.collect_to_s(
        TaxonNameRelationship::SourceClassifiedAs)
  end

  def self.disjoint_subject_classes
    TaxonNameClassification.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_object_classes
    TaxonNameClassification.descendants.collect{|t| t.to_s}
  end

  def self.nomenclatural_priority
    :reverse
  end

end
