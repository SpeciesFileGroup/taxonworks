class NomenclaturalRank::Icn::Governed::FamilyGroup::Tribe < NomenclaturalRank::Icn::Governed::FamilyGroup

  def self.parent_rank
      NomenclaturalRank::Icn::Governed::FamilyGroup::Subfamily
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -inae') if not(taxon_name.name =~ /.*inae\Z/)
    taxon_name.errors.add(:name, 'name must not end in -virinae') if (taxon_name.name =~ /.*virinae\Z/)
  end

end
