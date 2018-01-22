class NomenclaturalRank::Icnb::SpeciesGroup::Subspecies < NomenclaturalRank::Icnb::SpeciesGroup

  def self.parent_rank
    NomenclaturalRank::Icnb::SpeciesGroup::Species
  end

  def self.valid_parents
    [NomenclaturalRank::Icnb::SpeciesGroup::Species.to_s]
  end

  def self.abbreviation
    'subsp.'
  end
end
