class TaxonNameRelationship::OriginalCombination::OriginalClassifiedAs < TaxonNameRelationship::OriginalCombination

  validates_uniqueness_of :object_taxon_name_id, scope: :type

  # left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Iczn::HigherClassificationGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn::HigherClassificationGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn::FamilyGroup.descendants.collect{|t| t.to_s}
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_taxon_name_relationships
    TaxonNameRelationship::Combination.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_subject_classes
    [TaxonNameClass::Icn::NotEffectivelyPublished.to_s] +
        TaxonNameClass::Icn::EffectivelyPublished::InvalidlyPublished.descendants.collect{|t| t.to_s} +
        TaxonNameClass::Iczn::Unavailable.descendants.collect{|t| t.to_s}
  end

  def self.assignment_method
    :source_classified_as
  end

  def self.assignable
    true
  end

end
