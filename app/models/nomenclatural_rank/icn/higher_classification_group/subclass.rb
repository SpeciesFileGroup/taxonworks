class NomenclaturalRank::Icn::HigherClassificationGroup::Subclass < NomenclaturalRank::Icn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icn::HigherClassificationGroup::ClassRank
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -idae, -phycidae, or -mycetidae') if not(taxon_name.name =~ /.*idae|mycetidae|phycidae\Z/)
    taxon_name.errors.add(:name, 'name must not end in -viridae') if (taxon_name.name =~ /.*viridae\Z/)
  end

  def self.valid_name_ending
    'idae'
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::HigherClassificationGroup::ClassRank.to_s]
  end
end
