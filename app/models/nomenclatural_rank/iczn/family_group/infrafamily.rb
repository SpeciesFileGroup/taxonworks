class NomenclaturalRank::Iczn::FamilyGroup::Infrafamily < NomenclaturalRank::Iczn::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::FamilyGroup::Subfamily
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    #taxon_name.errors.add(:name, 'name must end in -odd') if not(taxon_name.name =~ /.*odd\Z/)
  end

  def self.valid_parents
    [NomenclaturalRank::Iczn::FamilyGroup::Subfamily.to_s]
  end

  #def self.valid_name_ending
    #'odd'
  #end


  def self.typical_use
    false
  end

end
