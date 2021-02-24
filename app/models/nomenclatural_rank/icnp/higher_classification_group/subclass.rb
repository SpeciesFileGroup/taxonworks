class NomenclaturalRank::Icnp::HigherClassificationGroup::Subclass < NomenclaturalRank::Icnp::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icnp::HigherClassificationGroup::ClassRank
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -idae') if not(taxon_name.name =~ /.*idae\Z/)
  end

  def self.valid_name_ending
    'idae'
  end

  def self.valid_parents
    [NomenclaturalRank::Icnp::HigherClassificationGroup::ClassRank.to_s]
  end
end
