class NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup <  NomenclaturalRank::Icn

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be lower case') unless taxon_name.name == taxon_name.name.downcase
    taxon_name.errors.add(:name, 'name must be at least two letters') unless taxon_name.name.length > 1
   end

  def self.valid_parents
    NomenclaturalRank::Icn::SpeciesAndInfraspeciesGroup.descendants + [NomenclaturalRank::Icn::Species]
  end
end
