class NomenclaturalRank::Icnb::SpeciesGroup <  NomenclaturalRank::Icnb

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be at least two letters') unless  !taxon_name.name.blank? && taxon_name.name.length > 1
   end

  def self.valid_parents
    self.collect_descendants_to_s(
        NomenclaturalRank::Icnb::GenusGroup,
        NomenclaturalRank::Icnb::SpeciesGroup)
  end
end
