class NomenclaturalRank::Icn::HigherClassificationGroup::ClassRank < NomenclaturalRank::Icn::HigherClassificationGroup

  def self.parent_rank
     NomenclaturalRank::Icn::HigherClassificationGroup::Subphylum
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -opsida, -phyceae, or -mycetes') if not(taxon_name.name =~ /.*opsida|phyceae|mycetes\Z/)
  end

  def rank_name
    "class"
  end

end
