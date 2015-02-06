class TaxonNameClassification::Iczn::Available::Invalid::Homonym < TaxonNameClassification::Iczn::Available::Invalid

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000043'

  LABEL = 'homonym, ICZN'

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_to_s(TaxonNameClassification::Iczn::Available::Invalid)
  end

end
