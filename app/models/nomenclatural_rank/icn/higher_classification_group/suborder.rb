class NomenclaturalRank::Icn::HigherClassificationGroup::Suborder < NomenclaturalRank::Icn::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icn::HigherClassificationGroup::Order
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -ineae') unless(taxon_name.name =~ /.*ineae\Z/)
    taxon_name.errors.add(:name, 'name must not end in -virineae') if(taxon_name.name =~ /.*virineae\Z/)
  end

  def self.valid_parents
    [NomenclaturalRank::Icn::HigherClassificationGroup::Order.to_s]
  end
end
