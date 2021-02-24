class NomenclaturalRank::Icnp::FamilyGroup::Subfamily < NomenclaturalRank::Icnp::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Icnp::FamilyGroup::Family
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -oideae') if not(taxon_name.name =~ /.*oideae\Z/)
  end

  def self.valid_parents
    [NomenclaturalRank::Icnp::FamilyGroup::Family.to_s]
  end

  def self.valid_name_ending
    'oideae'
  end

  def self.abbreviation
    'subfam.'
  end
end
