class TaxonNameRelationship::Typification::Family < TaxonNameRelationship::Typification

  # left side
  def self.valid_subject_ranks
    NomenclaturalRank::Iczn::GenusGroup.descendants + NomenclaturalRank::Icn::GenusGroup.descendants
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn::FamilyGroup.descendants + NomenclaturalRank::Icn::FamilyGroup.descendants
  end

  def self.assignment_method
    :type_genus
  end

  def self.assignable
    true
  end

end
