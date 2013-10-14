class NomenclaturalRank::Iczn::GenusGroup < NomenclaturalRank::Iczn

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be capitalized') if not(taxon_name.name == taxon_name.name.capitalize)
  end

end
