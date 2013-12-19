class TaxonNameRelationship::Icn::Accepting < TaxonNameRelationship::Icn

  def self.disjoint_taxon_name_relationships
    self.parent.disjoint_taxon_name_relationships +
        TaxonNameRelationship::Icn::Unaccepting.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_subject_classes
    self.parent.disjoint_subject_classes +
        [TaxonNameClass::Icn::NotEffectivelyPublished.to_s] +
        TaxonNameClass::Icn::EffectivelyPublished::InvalidlyPublished.descendants.collect{|t| t.to_s} +
        TaxonNameClass::Iczn::EffectivelyPublished::ValidlyPublished::Illegitimate.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_object_classes
    self.parent.disjoint_object_classes +
        [TaxonNameClass::Icn::NotEffectivelyPublished.to_s] +
        TaxonNameClass::Icn::EffectivelyPublished::InvalidlyPublished.descendants.collect{|t| t.to_s} +
        TaxonNameClass::Iczn::EffectivelyPublished::ValidlyPublished::Illegitimate.descendants.collect{|t| t.to_s}
  end

end