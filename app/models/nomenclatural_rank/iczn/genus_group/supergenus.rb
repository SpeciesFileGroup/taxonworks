class NomenclaturalRank::Iczn::GenusGroup::Supergenus < NomenclaturalRank::Iczn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::FamilyGroup::Infratribe
  end

  def self.typical_use
    false
  end

  def self.abbreviation
    'supergen.'
  end
end
