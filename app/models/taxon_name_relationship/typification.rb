class TaxonNameRelationship::Typification < TaxonNameRelationship

  def self.assignable
    false
  end

  def self.disjoint_taxon_name_relationships
    self.collect_descendants_to_s(TaxonNameRelationship::Combination)
  end

  @@disjoint_classes = self.collect_descendants_and_itself_to_s(TaxonNameClassification::Iczn::Unavailable,
          TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
          TaxonNameClassification::Icn::NotEffectivelyPublished)

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
