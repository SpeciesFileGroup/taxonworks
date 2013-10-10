class NomenclaturalRank::Icn::AboveFamily::Phylum < NomenclaturalRank::Icn::AboveFamily

  def self.parent_rank
     NomenclaturalRank::Icn::AboveFamily::Subregnum
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -phyta, -phycota, or -mycota') if not(taxon_name.name =~ /.*phyta|phycota|mycota\Z/)
  end

end
