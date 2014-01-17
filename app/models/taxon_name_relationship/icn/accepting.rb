class TaxonNameRelationship::Icn::Accepting < TaxonNameRelationship::Icn


  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        [TaxonNameRelationship::Icn::Unaccepting.to_s] +
        TaxonNameRelationship::Icn::Unaccepting.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        [TaxonNameClassification::Icn::NotEffectivelyPublished.to_s] +
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished.descendants.collect{|t| t.to_s} +
        TaxonNameClassification::Iczn::EffectivelyPublished::ValidlyPublished::Illegitimate.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        [TaxonNameClassification::Icn::NotEffectivelyPublished.to_s] +
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished.descendants.collect{|t| t.to_s} +
        TaxonNameClassification::Iczn::EffectivelyPublished::ValidlyPublished::Illegitimate.descendants.collect{|t| t.to_s}
  end

end