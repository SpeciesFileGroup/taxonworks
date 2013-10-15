class NomenclaturalRank::Iczn::AboveFamilyGroup < NomenclaturalRank::Iczn

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be capitalized') unless(taxon_name.name == taxon_name.name.capitalize)
  end

end
