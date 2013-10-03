class NomenclaturalRank::Iczn::Governed::FamilyGroup::Tribe < NomenclaturalRank::Iczn::Governed::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::Governed::FamilyGroup::Supertribe
  end

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must end in ini') if not(taxon_name.name =~ /.*ini\Z/)
    taxon_name.errors.add(:name, 'name must be capitalized') if not(taxon_name.name = taxon_name.name.capitalize)
  end
end
