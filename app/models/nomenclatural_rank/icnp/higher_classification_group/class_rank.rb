class NomenclaturalRank::Icnp::HigherClassificationGroup::ClassRank < NomenclaturalRank::Icnp::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icnp::HigherClassificationGroup::Phylum
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -ia') if not(taxon_name.name =~ /.*ia\Z/)
  end

  def self.valid_name_ending
    'ia'
  end

  def rank_name
    'class'
  end

end
