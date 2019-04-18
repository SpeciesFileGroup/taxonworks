class NomenclaturalRank::Icnp::FamilyGroup < NomenclaturalRank::Icnp

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be capitalized') unless  !taxon_name.name.blank? && taxon_name.name == taxon_name.name.capitalize
  end

  def self.valid_parents
    self.collect_descendants_to_s(
        NomenclaturalRank::Icnp::HigherClassificationGroup,
        NomenclaturalRank::Icnp::FamilyGroup)
  end
end
