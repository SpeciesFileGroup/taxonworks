class NomenclaturalRank::Icvcn::Family < NomenclaturalRank::Icvcn

  def self.parent_rank
    NomenclaturalRank::Icvcn::Order
  end

  def self.validate_name_format(taxon_name)
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must be capitalized') unless  !taxon_name.name.blank? && taxon_name.name == taxon_name.name.capitalize
    taxon_name.errors.add(:name, 'name must end in -viridae or -viroidae or -satellitidae') if not(taxon_name.name =~ /.*(viridae|viroidae|satellitidae)\Z/)
  end

  def self.valid_name_ending
    'idae'
  end

  def self.abbreviation
    'fam.'
  end

end