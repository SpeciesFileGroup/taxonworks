class NomenclaturalRank::Iczn::FamilyGroup::SubfamilyGroup < NomenclaturalRank::Iczn::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::FamilyGroup::Family
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -inae') if not(taxon_name.name =~ /.*inae\Z/)
  end

  def self.valid_parents
    NomenclaturalRank::Iczn::FamilyGroup::Family
  end

  def self.common
    false
  end

end
