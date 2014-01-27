class NomenclaturalRank::Icn::GenusGroup::Series < NomenclaturalRank::Icn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Icn::GenusGroup::Subsection
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::GenusGroup::Genus.to_s] + [NomenclaturalRank::Icn::GenusGroup::Subgenus.to_s] + [NomenclaturalRank::Icn::GenusGroup::Section.to_s] + [NomenclaturalRank::Icn::GenusGroup::Subsection.to_s]
  end

  def self.abbreviation
    "ser."
  end
end
