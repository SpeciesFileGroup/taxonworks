class TaxonNameClassification::Iczn::Available::Invalid::Homonym < TaxonNameClassification::Iczn::Available::Invalid

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClassification::Iczn::Available::Invalid.to_s]
  end

end