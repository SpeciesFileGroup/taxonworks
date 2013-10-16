class NomenclaturalRank::Icn::Species < NomenclaturalRank::Icn

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be lower case') if not(taxon_name.name == taxon_name.name.downcase)
  end

  def self.parent_rank
    NomenclaturalRank::Icn::GenusGroup::Subseries
  end

  def self.valid_parents
    NomenclaturalRank::Icn::GenusGroup.descendants
  end

  def self.abbreviation
    "sp."
  end

end
