class NomenclaturalRank::Ictv::Kingdom < NomenclaturalRank::Ictv

  def self.parent_rank
    NomenclaturalRank::Ictv
  end

  def self.validate_name_format(taxon_name)
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, "Should be 'Viruses'") if taxon_name.name != 'Viruses'
  end

end