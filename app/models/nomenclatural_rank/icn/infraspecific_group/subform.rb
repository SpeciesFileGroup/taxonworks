class NomenclaturalRank::Icn::InfraspecificGroup::Subform < NomenclaturalRank::Icn::InfraspecificGroup

  def self.parent_rank
    NomenclaturalRank::Icn::InfraspecificGroup::Form
  end

  def self.available_parents
    NomenclaturalRank::Icn::InfraspecificGroup::Form
  end

  def self.abbreviation
    "subf."
  end
end
