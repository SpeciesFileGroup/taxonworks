class NomenclaturalRank::Iczn::FamilyGroup::Subtribe < NomenclaturalRank::Iczn::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::FamilyGroup::Tribe
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -ina') if not(taxon_name.name =~ /.*ina\Z/)
  end

  def self.available_parents
    NomenclaturalRank::Iczn::FamilyGroup::Tribe
  end
  def self.abbreviation
    "subtr."
  end
end
