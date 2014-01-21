class NomenclaturalRank::Icn::FamilyGroup < NomenclaturalRank::Icn

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be capitalized') unless taxon_name.name = taxon_name.name.capitalize
  end

  def self.valid_parents
    self.collect_descendants_to_s(
        NomenclaturalRank::Icn::HigherClassificationGroup,
        NomenclaturalRank::Icn::FamilyGroup)
  end
end
