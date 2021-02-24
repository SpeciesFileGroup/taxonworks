class NomenclaturalRank::Icnp::FamilyGroup::Subtribe < NomenclaturalRank::Icnp::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Icnp::FamilyGroup::Tribe
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -inae') unless(taxon_name.name =~ /.*inae\Z/)
  end

  def self.valid_parents
    [NomenclaturalRank::Icnp::FamilyGroup::Tribe.to_s]
  end

  def self.valid_name_ending
    'inae'
  end

  def self.abbreviation
    'subtr.'
  end
end
