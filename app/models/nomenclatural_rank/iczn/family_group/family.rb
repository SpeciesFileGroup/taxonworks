class NomenclaturalRank::Iczn::FamilyGroup::Family < NomenclaturalRank::Iczn::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::FamilyGroup::Epifamily
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -idae') if not(taxon_name.name =~ /.*idae\Z/)
  end

  def self.abbreviation
    "fam."
  end
end
