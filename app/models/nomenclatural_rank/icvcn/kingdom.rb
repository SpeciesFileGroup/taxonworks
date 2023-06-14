class NomenclaturalRank::Icvcn::Kingdom < NomenclaturalRank::Icvcn

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
    NomenclaturalRank::Icvcn::Realm
  end

  def self.validate_name_format(taxon_name)
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, "Should be 'Viruses'") if taxon_name.name != 'Viruses'
    taxon_name.errors.add(:name, 'name must end in -virae') if not(taxon_name.name =~ /.*(virae)\Z/)
  end

  def self.valid_name_ending
    'virae'
  end

end
