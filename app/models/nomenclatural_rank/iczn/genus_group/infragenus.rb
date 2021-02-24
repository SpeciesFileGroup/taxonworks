class NomenclaturalRank::Iczn::GenusGroup::Infragenus < NomenclaturalRank::Iczn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::GenusGroup::Subgenus
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::GenusGroup::Subgenus.to_s]
  end

  def self.typical_use
    false
  end

  def self.abbreviation
    'infragen.'
  end
end
