class NomenclaturalRank::Icnb::HigherClassificationGroup < NomenclaturalRank::Icnb

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'must be capitalized') unless  !taxon_name.name.blank? && taxon_name.name == taxon_name.name.capitalize
    taxon_name.errors.add(:name, 'must be at least two letters') unless taxon_name.name.length > 1
  end

  def self.valid_parents
    self.collect_descendants_to_s(
        NomenclaturalRank::Icnb::HigherClassificationGroup)
  end

end
