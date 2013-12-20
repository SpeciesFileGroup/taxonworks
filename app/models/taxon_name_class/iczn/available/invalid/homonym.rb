class TaxonNameClass::Iczn::Available::Invalid::Homonym < TaxonNameClass::Iczn::Available::Invalid

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClass::Iczn::Available::Invalid.to_s]
  end

end