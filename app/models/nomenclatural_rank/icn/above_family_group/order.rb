class NomenclaturalRank::Icn::AboveFamilyGroup::Order < NomenclaturalRank::Icn::AboveFamilyGroup

  def self.parent_rank
     NomenclaturalRank::Icn::AboveFamilyGroup::Subclass
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -ales') unless(taxon_name.name =~ /.*ales\Z/)
    taxon_name.errors.add(:name, 'name must not end in -virales') if(taxon_name.name =~ /.*virales\Z/)
  end

end
