class NomenclaturalRank::Icn::InfraspecificGroup::Subspecies < NomenclaturalRank::Icn::InfraspecificGroup

  def self.parent_rank
    NomenclaturalRank::Icn::Species
  end

  def self.valid_parents
    NomenclaturalRank::Icn::Species
  end

  def self.abbreviation
    "subsp."
  end
end
