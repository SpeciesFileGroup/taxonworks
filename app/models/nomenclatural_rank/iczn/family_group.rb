class NomenclaturalRank::Iczn::FamilyGroup < NomenclaturalRank::Iczn

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be capitalized') unless taxon_name.name == taxon_name.name.capitalize
  end

  def self.valid_parents
    NomenclaturalRank::Iczn::HigherClassificationGroup.descendants.collect{|t| t.to_s} + NomenclaturalRank::Iczn::FamilyGroup.descendants.collect{|t| t.to_s}
  end
end
