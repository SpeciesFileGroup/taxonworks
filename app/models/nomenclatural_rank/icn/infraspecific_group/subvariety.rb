class NomenclaturalRank::Icn::InfraspecificGroup::Subvariety < NomenclaturalRank::Icn::InfraspecificGroup

  def self.parent_rank
    NomenclaturalRank::Icn::InfraspecificGroup::Variety
  end

  def self.available_parents
    NomenclaturalRank::Icn::InfraspecificGroup::Variety
  end

  def self.abbreviation
    "subvar."
  end
end
