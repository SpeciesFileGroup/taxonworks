class NomenclaturalRank::Iczn::SpeciesGroup::Subspecies < NomenclaturalRank::Iczn::SpeciesGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::SpeciesGroup::Species
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::SpeciesGroup::Species.to_s]
  end

  def self.typical_use
    true
  end

  def self.abbreviation
    'ssp.'
  end
end
