class NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup <  NomenclaturalRank::Icn

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be lower case') unless taxon_name.name == taxon_name.name.downcase
    taxon_name.errors.add(:name, 'name must be at least two letters') unless taxon_name.name.length > 1
   end

  def self.valid_parents
    self.collect_descendants_to_s(
        NomenclaturalRank::Icn::GenusGroup,
        NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup)
  end
end
