class NomenclaturalRank::Iczn::Governed::FamilyGroup::SubfamilyGroup < NomenclaturalRank::Iczn::Governed::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::Governed::FamilyGroup::Family
  end

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must end in -inae') if not(taxon_name.name =~ /.*inae\Z/)
    taxon_name.errors.add(:name, 'name must be capitalized') if not(taxon_name.name = taxon_name.name.capitalize)
  end

end
