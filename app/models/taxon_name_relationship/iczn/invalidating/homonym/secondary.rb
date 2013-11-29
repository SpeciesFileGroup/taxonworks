class TaxonNameRelationship::Iczn::Invalidating::Homonym::Secondary < TaxonNameRelationship::Iczn::Invalidating::Homonym

  # left_side
  def self.valid_subject_ranks
    NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
  end

  # right_side
  def self.valid_object_ranks
    NomenclaturalRank::Iczn::SpeciesGroup.descendants.collect{|t| t.to_s}
  end

end
