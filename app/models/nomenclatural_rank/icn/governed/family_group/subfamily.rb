class NomenclaturalRank::Icn::Governed::FamilyGroup::Subfamily < NomenclaturalRank::Icn::Governed::FamilyGroup

  def self.parent_rank
      NomenclaturalRank::Icn::Governed::FamilyGroup::Family
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -oideae') if not(taxon_name.name =~ /.*oideae\Z/)
  end

end
