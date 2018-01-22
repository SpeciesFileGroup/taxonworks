class NomenclaturalRank::Icnb::FamilyGroup::Tribe < NomenclaturalRank::Icnb::FamilyGroup

  def self.parent_rank
      NomenclaturalRank::Icnb::FamilyGroup::Subfamily
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -eae') unless(taxon_name.name =~ /.*eae\Z/)
  end

  def self.valid_parents
    [NomenclaturalRank::Icnb::FamilyGroup::Subfamily.to_s]
  end

  def self.abbreviation
    'tr.'
  end
end
