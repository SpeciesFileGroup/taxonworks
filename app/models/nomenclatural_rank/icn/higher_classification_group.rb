class NomenclaturalRank::Icn::HigherClassificationGroup < NomenclaturalRank::Icn

  def self.validate_name_format(taxon_name)
    if !taxon_name.name.blank?
      taxon_name.errors.add(:name, 'must be capitalized') unless taxon_name.name == taxon_name.name.capitalize

      # TODO: this should be inherited/applied higher up?
      taxon_name.errors.add(:name, 'must be at least two letters') unless taxon_name.name.length > 1
    end
  end

  def self.valid_parents
    self.collect_descendants_to_s(
      NomenclaturalRank::Icn::HigherClassificationGroup)
  end

end
