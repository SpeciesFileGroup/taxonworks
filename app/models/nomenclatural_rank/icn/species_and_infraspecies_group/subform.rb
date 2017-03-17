class NomenclaturalRank::Icn::SpeciesGroup::Subform < NomenclaturalRank::Icn::SpeciesGroup

  def self.parent_rank
    NomenclaturalRank::Icn::SpeciesGroup::Form
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::SpeciesGroup::Form.to_s]
  end

  def self.abbreviation
    "subf."
  end
end
