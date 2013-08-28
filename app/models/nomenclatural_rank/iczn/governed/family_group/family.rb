class NomenclaturalRank::Iczn::Governed::FamilyGroup::Family < NomenclaturalRank::Iczn::Governed::FamilyGroup

  def self.parent_rank
    NomenclaturalRank::Iczn::Governed::FamilyGroup::Epifamily
  end

  def self.validate_name_format(taxon_name)
    taxon_name.errors.add(:name, 'name must end in idae') if not(taxon_name.name =~ /.*idae\Z/)
  end

end
