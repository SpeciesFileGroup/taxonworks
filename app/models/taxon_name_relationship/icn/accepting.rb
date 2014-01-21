class TaxonNameRelationship::Icn::Accepting < TaxonNameRelationship::Icn


  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships + self.collect_descendants_and_itself_to_s(
        TaxonNameRelationship::Icn::Unaccepting)
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes + self.collect_to_s(
        TaxonNameClassification::Icn::NotEffectivelyPublished) + self.collect_descendants_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished,
        TaxonNameClassification::Iczn::EffectivelyPublished::ValidlyPublished::Illegitimate)
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        [TaxonNameClassification::Icn::NotEffectivelyPublished.to_s] +
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished.descendants.collect{|t| t.to_s} +
        TaxonNameClassification::Iczn::EffectivelyPublished::ValidlyPublished::Illegitimate.descendants.collect{|t| t.to_s}
  end

end