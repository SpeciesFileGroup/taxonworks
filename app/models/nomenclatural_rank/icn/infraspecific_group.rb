class NomenclaturalRank::Icn::InfraspecificGroup <  NomenclaturalRank::Icn

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be lower case') if not(taxon_name.name == taxon_name.name.downcase)
  end

  def self.valid_parents
    NomenclaturalRank::Icn::InfraspecificGroup.descendants + NomenclaturalRank::Icn::Species
  end
end
