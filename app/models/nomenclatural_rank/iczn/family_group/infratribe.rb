class NomenclaturalRank::Iczn::FamilyGroup::Infratribe < NomenclaturalRank::Iczn::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::FamilyGroup::Subtribe
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -ad') if not(taxon_name.name =~ /.*ad\Z/)
  end


end
