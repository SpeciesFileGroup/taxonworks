class NomenclaturalRank::Icn::FamilyGroup < NomenclaturalRank::Icn

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must be capitalized') unless taxon_name.name = taxon_name.name.capitalize
    taxon_name.errors.add(:name, 'name must be at least two letters') unless taxon_name.name.length > 1

  end

  def self.valid_parents
    NomenclaturalRank::Icn::FamilyGroup.descendants + NomenclaturalRank::Icn::AboveFamilyGroup.descendants
  end
end
