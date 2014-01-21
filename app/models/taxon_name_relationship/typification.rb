class TaxonNameRelationship::Typification < TaxonNameRelationship

  def self.assignable
    false
  end

  def self.disjoint_taxon_name_relationships
    self.collect_descendants_to_s(
        TaxonNameRelationship::Combination)
  end

  def self.disjoint_subject_classes
    self.collect_descendants_and_itself_to_s(
        TaxonNameClassification::Iczn::Unavailable) + self.collect_descendants_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished) + self.collect_to_s(
        TaxonNameClassification::Icn::NotEffectivelyPublished)

  end

  def self.disjoint_object_classes
    self.collect_descendants_and_itself_to_s(
        TaxonNameClassification::Iczn::Unavailable) + self.collect_descendants_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished) + self.collect_to_s(
        TaxonNameClassification::Icn::NotEffectivelyPublished)        
  end

  def self.nomenclatural_priority
    :reverse
  end

end
