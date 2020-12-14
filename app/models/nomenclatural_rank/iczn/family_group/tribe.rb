class NomenclaturalRank::Iczn::FamilyGroup::Tribe < NomenclaturalRank::Iczn::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::FamilyGroup::Supertribe
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -ini') if not(taxon_name.name =~ /.*ini\Z/)
  end

  def self.valid_name_ending
    'ini'
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::FamilyGroup::Supertribe.to_s, NomenclaturalRank::Iczn::FamilyGroup::Subfamily.to_s]
  end

  def self.abbreviation
    'tr.'
  end
end
