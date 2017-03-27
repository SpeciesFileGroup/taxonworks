class NomenclaturalRank::Icn::SpeciesGroup::Variety < NomenclaturalRank::Icn::SpeciesGroup

  def self.parent_rank
    NomenclaturalRank::Icn::SpeciesGroup::Subspecies
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::SpeciesGroup::Species.to_s] + [NomenclaturalRank::Icn::SpeciesGroup::Subspecies.to_s]
  end

  def self.abbreviation
    "var."
  end
end
