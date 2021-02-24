class NomenclaturalRank::Icn::HigherClassificationGroup::Subphylum < NomenclaturalRank::Icn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icn::HigherClassificationGroup::Phylum
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -phytina, -phycotina, or -mycotina') if not(taxon_name.name =~ /.*phytina|phycotina|mycotina\Z/)
  end

  def self.valid_name_ending
    'ina'
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::HigherClassificationGroup::Phylum.to_s]
  end
end
