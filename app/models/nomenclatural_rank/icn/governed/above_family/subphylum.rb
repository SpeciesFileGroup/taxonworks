class NomenclaturalRank::Icn::Governed::AboveFamily::Subphylum < NomenclaturalRank::Icn::Governed::AboveFamily

  def self.parent_rank
    NomenclaturalRank::Icn::Governed::AboveFamily::Phylum
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -phytina, -phycotina, or -mycotina') if not(taxon_name.name =~ /.*phytina|phycotina|mycotina\Z/)
  end


end
