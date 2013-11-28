class NomenclaturalRank::Iczn::SpeciesGroup::SpeciesSubgroup < NomenclaturalRank::Iczn::SpeciesGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::SpeciesGroup::SpeciesGroup
  end

  def self.typical_use
    false
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::SpeciesGroup::SpeciesGroup.to_s]
  end

end
