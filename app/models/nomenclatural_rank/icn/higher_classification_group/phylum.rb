class NomenclaturalRank::Icn::HigherClassificationGroup::Phylum < NomenclaturalRank::Icn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icn::HigherClassificationGroup::Subkingdom
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -phyta, -phycota, or -mycota') if not (taxon_name.name =~ /.*phyta|phycota|mycota\Z/)
  end

  def self.valid_name_ending
    'ta'
  end

end
