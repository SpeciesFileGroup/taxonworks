class NomenclaturalRank::Icn::InfraspecificGroup <  NomenclaturalRank::Icn

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be lower case') if not(taxon_name.name == taxon_name.name.downcase)
  end

end
