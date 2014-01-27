class TaxonNameClassification::Iczn::Available::Invalid::Homonym < TaxonNameClassification::Iczn::Available::Invalid

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_to_s(TaxonNameClassification::Iczn::Available::Invalid)
  end

end