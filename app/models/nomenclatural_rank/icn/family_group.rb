class NomenclaturalRank::Icn::FamilyGroup < NomenclaturalRank::Icn

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be capitalized') unless taxon_name.name = taxon_name.name.capitalize
  end

  def self.valid_parents
    NomenclaturalRank::Icn::HigherClassificationGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Icn::FamilyGroup.descendants.collect{|t| t.to_s}
  end
end
