class TaxonNameRelationship::Typification::Family < TaxonNameRelationship::Typification

  # left side
  def self.valid_subject_ranks
    NomenclaturalRank::ICZN::GenusGroup.descendants + NomenclaturalRank::ICN::GenusGroup.descendants
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::ICZN::FamilyGroup.descendants + NomenclaturalRank::ICN::FamilyGroup.descendants
  end

  def self.assignment_method
    :type_genus
  end

end
