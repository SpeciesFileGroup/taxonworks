class NomenclaturalRank::Icn::InfraspecificGroup::Subform < NomenclaturalRank::Icn::InfraspecificGroup

  def self.parent_rank
    NomenclaturalRank::Icn::InfraspecificGroup::Form
  end

  def self.valid_parents
    NomenclaturalRank::Icn::InfraspecificGroup::Form
  end

  def self.abbreviation
    "subf."
  end
end
