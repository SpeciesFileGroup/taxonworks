class NomenclaturalRank::Icnp::HigherClassificationGroup::Order < NomenclaturalRank::Icnp::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icnp::HigherClassificationGroup::Subclass
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -ales') unless(taxon_name.name =~ /.*ales\Z/)
  end

  def self.valid_name_ending
    'ales'
  end

end
