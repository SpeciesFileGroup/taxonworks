class NomenclaturalRank::Icn::AboveFamilyGroup::Phylum < NomenclaturalRank::Icn::AboveFamilyGroup

  def self.parent_rank
     NomenclaturalRank::Icn::AboveFamilyGroup::Subkingdom
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -phyta, -phycota, or -mycota') if not(taxon_name.name =~ /.*phyta|phycota|mycota\Z/)
  end

end
