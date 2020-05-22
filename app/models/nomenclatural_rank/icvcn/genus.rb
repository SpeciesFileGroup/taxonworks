class NomenclaturalRank::Icvcn::Genus < NomenclaturalRank::Icvcn

  def self.parent_rank
    NomenclaturalRank::Icvcn::Subfamily
  end

  def self.validate_name_format(taxon_name)
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must be capitalized') unless  !taxon_name.name.blank? && taxon_name.name == taxon_name.name.capitalize
    taxon_name.errors.add(:name, 'name must end in -virus or -viroid or -satellite') if not(taxon_name.name =~ /.*(virus|viroid|satellite)\Z/)
  end

  def self.abbreviation
    'gen.'
  end

end