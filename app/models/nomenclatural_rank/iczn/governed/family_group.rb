class NomenclaturalRank::Iczn::Governed::FamilyGroup < NomenclaturalRank::Iczn::Governed

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be capitalized') if not(taxon_name.name = taxon_name.capitalize)
  end
end
