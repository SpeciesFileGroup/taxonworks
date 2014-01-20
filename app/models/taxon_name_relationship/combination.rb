class TaxonNameRelationship::Combination < TaxonNameRelationship
  # Abstract class.
  validates_uniqueness_of :object_taxon_name_id, scope: :type

  def self.disjoint_taxon_name_relationships
    TaxonNameRelationship::Iczn.descendants.collect{|t| t.to_s} +
    TaxonNameRelationship::Icn.descendants.collect{|t| t.to_s} +
    TaxonNameRelationship::OriginalCombination.descendants.collect{|t| t.to_s} +
    TaxonNameRelationship::Typification.descendants.collect{|t| t.to_s} +
    [TaxonNameRelationship::SourceClassifiedAs.to_s]
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
