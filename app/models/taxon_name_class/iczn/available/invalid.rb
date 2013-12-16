class TaxonNameClass::Iczn::Available::Invalid < TaxonNameClass::Iczn::Available

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClass::Iczn::Available::Valid.to_s]
  end

end
