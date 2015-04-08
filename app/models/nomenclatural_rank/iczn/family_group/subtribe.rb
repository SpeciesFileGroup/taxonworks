class NomenclaturalRank::Iczn::FamilyGroup::Subtribe < NomenclaturalRank::Iczn::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::FamilyGroup::Tribe
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -ina') if not(taxon_name.name =~ /.*ina\Z/)
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::FamilyGroup::Tribe.to_s]
  end

  def self.abbreviation
    "subtr."
  end
end
