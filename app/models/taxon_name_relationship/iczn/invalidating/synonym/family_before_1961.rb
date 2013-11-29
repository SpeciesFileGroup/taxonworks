class TaxonNameRelationship::Iczn::Invalidating::Synonym::FamilyBefore1961 < TaxonNameRelationship::Iczn::Invalidating::Synonym

  # left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
  end

end