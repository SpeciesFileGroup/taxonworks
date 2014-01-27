class NomenclaturalRank::Iczn::FamilyGroup < NomenclaturalRank::Iczn

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be capitalized') unless taxon_name.name == taxon_name.name.capitalize
  end

  def self.valid_parents
    self.collect_descendants_to_s(
        NomenclaturalRank::Iczn::HigherClassificationGroup,
        NomenclaturalRank::Iczn::FamilyGroup)
  end

  ENDINGS = %w{ini ina inae idae oidae odd ad oidea}
end
