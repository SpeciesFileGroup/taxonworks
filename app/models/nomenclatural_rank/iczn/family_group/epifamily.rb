class NomenclaturalRank::Iczn::FamilyGroup::Epifamily < NomenclaturalRank::Iczn::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::FamilyGroup::Superfamily
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -oidae') if not(taxon_name.name =~ /.*oidae\Z/)
  end

  def self.typical_use
    false
  end

end
