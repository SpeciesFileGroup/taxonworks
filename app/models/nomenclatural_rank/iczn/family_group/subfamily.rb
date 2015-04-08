class NomenclaturalRank::Iczn::FamilyGroup::Subfamily < NomenclaturalRank::Iczn::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::FamilyGroup::SubfamilyGroup
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -inae') if not(taxon_name.name =~ /.*inae\Z/)
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::FamilyGroup::Family.to_s, NomenclaturalRank::Iczn::FamilyGroup::SubfamilyGroup.to_s]
  end
end
