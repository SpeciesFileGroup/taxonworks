class NomenclaturalRank::Iczn::SpeciesGroup::Species < NomenclaturalRank::Iczn::SpeciesGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::SpeciesGroup::Subsuperspecies
  end

  def self.abbreviation
    'sp.'
  end
end
