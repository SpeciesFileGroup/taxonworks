class NomenclaturalRank::Icvcn::Realm < NomenclaturalRank::Icvcn

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
    NomenclaturalRank::Icvcn
  end

  def self.validate_name_format(taxon_name)
    return true if taxon_name.name.length < 2
    #taxon_name.errors.add(:name, "Should be 'Viruses'") if taxon_name.name != 'Viruses'
    taxon_name.errors.add(:name, 'name must end in -viria') if not(taxon_name.name =~ /.*(viria)\Z/)
  end

  def self.valid_name_ending
    'viria'
  end

end
