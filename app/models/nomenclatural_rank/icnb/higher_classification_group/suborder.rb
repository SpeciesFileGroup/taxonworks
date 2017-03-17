class NomenclaturalRank::Icnb::HigherClassificationGroup::Suborder < NomenclaturalRank::Icnb::HigherClassificationGroup

  def self.parent_rank
    NomenclaturalRank::Icnb::HigherClassificationGroup::Order
  end

  def self.validate_name_format(taxon_name)
    super
    return true if taxon_name.name.length < 2
    taxon_name.errors.add(:name, 'name must end in -ineae') unless(taxon_name.name =~ /.*ineae\Z/)
  end

  def self.valid_parents
    [NomenclaturalRank::Icnb::HigherClassificationGroup::Order.to_s]
  end
end
