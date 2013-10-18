class TaxonNameRelationship::Icn::Accepting::AlternativeFamilyName < TaxonNameRelationship::Icn::Accepting

  #left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Icn::FamilyGroup.descendants
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn::FamilyGroup.descendants
  end

end