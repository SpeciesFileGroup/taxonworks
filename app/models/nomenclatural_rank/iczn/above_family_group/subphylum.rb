class NomenclaturalRank::Iczn::AboveFamilyGroup::Subphylum < NomenclaturalRank::Iczn::AboveFamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::AboveFamilyGroup::Phylum
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::AboveFamilyGroup::Phylum.to_s]
  end

end
