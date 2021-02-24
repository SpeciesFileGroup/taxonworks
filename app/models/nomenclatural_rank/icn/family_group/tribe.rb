class NomenclaturalRank::Icn::FamilyGroup::Tribe < NomenclaturalRank::Icn::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Icn::FamilyGroup::Subfamily
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -eae') unless (taxon_name.name =~ /.*eae\Z/)
    taxon_name.errors.add(:name, 'name must not end in -vireae') if (taxon_name.name =~ /.*vireae\Z/)
  end

  def self.valid_name_ending
    nil
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::FamilyGroup::Subfamily.to_s]
  end

  def self.abbreviation
    'tr.'
  end
end
