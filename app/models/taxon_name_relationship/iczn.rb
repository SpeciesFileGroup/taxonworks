class TaxonNameRelationship::Iczn < TaxonNameRelationship
  validates_uniqueness_of :subject_taxon_name_id, scope: :type

  # left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Iczn.descendants.collect{|t| t.to_s}
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_taxon_name_relationships
    TaxonNameRelationship::Icn.descendants.collect{|t| t.to_s} +
    TaxonNameRelationship::Combination.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_subject_classes
        TaxonNameClass::Icn.descendants.collect{|t| t.to_s}
  end

  def self.disjoint_object_classes
    [TaxonNameClass::Icn::NotEffectivelyPublished.to_s]
  end


end
