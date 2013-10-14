class NomenclaturalRank::Icn::AboveFamily::Suborder < NomenclaturalRank::Icn::AboveFamily

  def self.parent_rank
    NomenclaturalRank::Icn::AboveFamily::Order
  end

  def self.validate_name_format(taxon_name)
    super
    taxon_name.errors.add(:name, 'name must end in -ineae') unless(taxon_name.name =~ /.*ineae\Z/)
    taxon_name.errors.add(:name, 'name must not end in -virineae') if(taxon_name.name =~ /.*virineae\Z/)
  end

end
