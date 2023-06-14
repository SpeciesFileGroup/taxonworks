class NomenclaturalRank::Icvcn::ClassRank < NomenclaturalRank::Icvcn

  # realm “‑viria”
  # subrealm “‑vira”
  # kingdom “‑virae”
  # subkingdom “‑virites”
  # phylum “‑viricota”
  # subphylum “‑viricotina”
  # class “‑viricetes”
  # subclass “‑viricetidae”
  # order “‑virales”
  # suborder “‑virineae”
  # family “‑viridae”
  # subfamily “‑virinae”
  # genus “‑virus”
  # subgenus “‑virus”

  def self.parent_rank
    NomenclaturalRank::Icvcn::Phylum
  end

  def self.validate_name_format(taxon_name)
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must be capitalized') unless  !taxon_name.name.blank? && taxon_name.name == taxon_name.name.capitalize
    taxon_name.errors.add(:name, 'name must end in -viricetes') if not(taxon_name.name =~ /.*(viricetes)\Z/)
  end

  def rank_name
    'class'
  end

  def self.valid_name_ending
    'viricetes'
  end

  #def self.abbreviation
  #  'ord.'
  #end

end
