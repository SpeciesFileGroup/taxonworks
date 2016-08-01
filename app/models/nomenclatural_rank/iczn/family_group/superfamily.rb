class NomenclaturalRank::Iczn::FamilyGroup::Superfamily < NomenclaturalRank::Iczn::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::HigherClassificationGroup::Nanorder
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -oidea') if not(taxon_name.name =~ /.*oidea\Z/)
  end

  def self.valid_name_ending
    'oidea'
  end

end
