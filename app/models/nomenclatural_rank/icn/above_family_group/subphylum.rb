class NomenclaturalRank::Icn::AboveFamilyGroup::Subphylum < NomenclaturalRank::Icn::AboveFamilyGroup

  def self.parent_rank
    NomenclaturalRank::Icn::AboveFamilyGroup::Phylum
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -phytina, -phycotina, or -mycotina') if not(taxon_name.name =~ /.*phytina|phycotina|mycotina\Z/)
  end

  def self.available_parents
    NomenclaturalRank::Icn::AboveFamilyGroup::Phylum
  end
end
