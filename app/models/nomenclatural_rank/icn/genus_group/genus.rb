class NomenclaturalRank::Icn::GenusGroup::Genus < NomenclaturalRank::Icn::GenusGroup

  def self.parent_rank
    NomenclaturalRank::Icn::FamilyGroup::Subtribe
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must not end in -virus') if (taxon_name.name =~ /.*virus\Z/)
  end

  def self.abbreviation
    "gen."
  end
end
