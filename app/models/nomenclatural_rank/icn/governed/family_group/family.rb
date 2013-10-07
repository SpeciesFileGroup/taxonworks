class NomenclaturalRank::Icn::Governed::FamilyGroup::Family < NomenclaturalRank::Icn::Governed::FamilyGroup

  def self.parent_rank
      NomenclaturalRank::Icn::Governed::AboveFamily::Suborder
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -aceae') if not(taxon_name.name =~ /.*aceae\Z/)
  end

end
