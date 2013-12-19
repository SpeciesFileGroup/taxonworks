class TaxonNameRelationship::Typification < TaxonNameRelationship

  def self.assignable
    false
  end

  def self.disjoint_taxon_name_relationships
    TaxonNameRelationship::Combination.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_subject_classes
    [TaxonNameClass::Icn::NotEffectivelyPublished.to_s] +
        TaxonNameClass::Icn::EffectivelyPublished::InvalidlyPublished.descendants.collect{|t| t.to_s} +
        TaxonNameClass::Iczn::Unavailable.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_object_classes
    [TaxonNameClass::Icn::NotEffectivelyPublished.to_s] +
        TaxonNameClass::Icn::EffectivelyPublished::InvalidlyPublished.descendants.collect{|t| t.to_s} +
        TaxonNameClass::Iczn::Unavailable.descendants.collect{|t| t.to_s}
  end


end
