class NomenclaturalRank::Icn::SpeciesGroup::Subspecies < NomenclaturalRank::Icn::SpeciesGroup

  def self.parent_rank
    NomenclaturalRank::Icn::SpeciesGroup::Species
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::SpeciesGroup::Species.to_s]
  end

  def self.abbreviation
    "subsp."
  end
end
