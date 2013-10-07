class NomenclaturalRank::Icn::Governed::GenusGroup::Genus < NomenclaturalRank::Icn::Governed::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Icn::Governed::FamilyGroup::Subtribe
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must not end in -virus') if (taxon_name.name =~ /.*virus\Z/)
  end

end
