class NomenclaturalRank::Icn::Governed::AboveFamily::ClassRank < NomenclaturalRank::Icn::Governed::AboveFamily

  def self.parent_rank
     NomenclaturalRank::Icn::Governed::AboveFamily::Subphylum
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -opsida, -phyceae, or -mycetes') if not(taxon_name.name =~ /.*opsida|phyceae|mycetes\Z/)
  end


  def name
    "class"
  end

end
