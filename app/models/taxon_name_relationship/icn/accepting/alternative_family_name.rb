class TaxonNameRelationship::Icn::Accepting::AlternativeFamilyName < TaxonNameRelationship::Icn::Accepting

  #left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Icn::FamilyGroup.descendants.collect{|t| t.to_s}
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
  end

  def self.assignable
    true
  end

end