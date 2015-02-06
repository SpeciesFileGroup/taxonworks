class TaxonNameClassification::Iczn::Available::Invalid < TaxonNameClassification::Iczn::Available

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000226'

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_to_s(TaxonNameClassification::Iczn::Available::Valid)
  end

  def self.gbif_status
    'invalidum'
  end

end
