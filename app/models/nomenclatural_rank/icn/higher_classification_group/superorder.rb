class NomenclaturalRank::Icn::HigherClassificationGroup::Superorder < NomenclaturalRank::Icn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icn::HigherClassificationGroup::Subclass
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -anae') unless(taxon_name.name =~ /.*anae\Z/)
    taxon_name.errors.add(:name, 'name must not end in -viranae') if(taxon_name.name =~ /.*viranae\Z/)
  end

  def self.valid_name_ending
    'anae'
  end

end
