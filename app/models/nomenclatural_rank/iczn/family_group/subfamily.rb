class NomenclaturalRank::Iczn::FamilyGroup::Subfamily < NomenclaturalRank::Iczn::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::FamilyGroup::SubfamilyGroup
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -inae') if not(taxon_name.name =~ /.*inae\Z/)
  end

  def self.available_parents
    [NomenclaturalRank::Iczn::FamilyGroup::Family, NomenclaturalRank::Iczn::FamilyGroup::SubfamilyGroup
  end
end
