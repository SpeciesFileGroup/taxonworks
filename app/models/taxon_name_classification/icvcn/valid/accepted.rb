class TaxonNameClassification::Icvcn::Valid::Accepted < TaxonNameClassification::Icvcn::Valid

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000127'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icvcn::Valid::Unaccepted)
  end

  def self.gbif_status
    'valid'
  end

  def self.assignable
    true
  end

end