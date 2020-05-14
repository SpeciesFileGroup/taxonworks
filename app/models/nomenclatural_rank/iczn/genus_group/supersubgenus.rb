class NomenclaturalRank::Iczn::GenusGroup::Supersubgenus < NomenclaturalRank::Iczn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::GenusGroup::Supersupersubgenus
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::GenusGroup::Genus.to_s]
  end

  def self.abbreviation
    'supersubgen.'
  end

  def self.typical_use
    false
  end

end
