class TaxonNameRelationship::Typification < TaxonNameRelationship

  def self.assignable
    false
  end

  def self.disjoint_taxon_name_relationships
    TaxonNameRelationship::Combination.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_subject_classes
    [TaxonNameClassification::Icn::NotEffectivelyPublished.to_s] +
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished.descendants.collect{|t| t.to_s} +
        TaxonNameClassification::Iczn::Unavailable.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Unavailable.to_s]
  end

  def self.disjoint_object_classes
    [TaxonNameClassification::Icn::NotEffectivelyPublished.to_s] +
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished.descendants.collect{|t| t.to_s} +
        TaxonNameClassification::Iczn::Unavailable.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Iczn::Unavailable.to_s]
  end

  def self.priority
    :reverse
  end

end
