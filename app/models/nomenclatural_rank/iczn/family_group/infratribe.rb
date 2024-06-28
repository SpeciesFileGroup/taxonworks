class NomenclaturalRank::Iczn::FamilyGroup::Infratribe < NomenclaturalRank::Iczn::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::FamilyGroup::Subtribe
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    #taxon_name.errors.add(:name, 'name must end in -ad') if not(taxon_name.name =~ /.*ad\Z/)
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::FamilyGroup::Subtribe.to_s]
  end

  #def self.valid_name_ending
    #'ad'
  #end


  def self.typical_use
    false
  end

end
