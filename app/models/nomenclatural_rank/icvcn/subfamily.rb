class NomenclaturalRank::Icvcn::Subfamily < NomenclaturalRank::Icvcn

  def self.parent_rank
    NomenclaturalRank::Icvcn::Family
  end

  def self.validate_name_format(taxon_name)
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must be capitalized') unless  !taxon_name.name.blank? && taxon_name.name == taxon_name.name.capitalize
    taxon_name.errors.add(:name, 'name must end in -virinae or -viroinae or -satellitinae') if not(taxon_name.name =~ /.*(virinae|viroinae|satellitinae)\Z/)
  end

  def self.valid_name_ending
    'inae'
  end

  def self.abbreviation
    'subfam.'
  end

end