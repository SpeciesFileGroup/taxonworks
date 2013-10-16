class NomenclaturalRank::Icn::FamilyGroup::Subtribe < NomenclaturalRank::Icn::FamilyGroup

  def self.parent_rank
      NomenclaturalRank::Icn::FamilyGroup::Tribe
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -inae') unless(taxon_name.name =~ /.*inae\Z/)
    taxon_name.errors.add(:name, 'name must not end in -virinae') if (taxon_name.name =~ /.*virinae\Z/)
  end

  def self.available_parents
    NomenclaturalRank::Icn::FamilyGroup::Tribe
  end

  def self.abbreviation
    "subtr."
  end
end
