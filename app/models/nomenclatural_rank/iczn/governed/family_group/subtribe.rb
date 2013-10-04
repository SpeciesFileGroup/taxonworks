class NomenclaturalRank::Iczn::Governed::FamilyGroup::Subtribe < NomenclaturalRank::Iczn::Governed::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::Governed::FamilyGroup::Tribe
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -ina') if not(taxon_name.name =~ /.*ina\Z/)
  end
end
