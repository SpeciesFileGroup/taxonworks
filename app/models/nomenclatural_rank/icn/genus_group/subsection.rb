class NomenclaturalRank::Icn::GenusGroup::Subsection < NomenclaturalRank::Icn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Icn::GenusGroup::Section
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::GenusGroup::Section.to_s]
  end

  def self.abbreviation
    "subsect."
  end
end
