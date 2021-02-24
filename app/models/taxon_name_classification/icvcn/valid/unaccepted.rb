class TaxonNameClassification::Icvcn::Valid::Unaccepted < TaxonNameClassification::Icvcn::Valid

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000128'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icvcn::Valid::Accepted)
  end

  def self.gbif_status
    'invalidum'
  end

  def self.assignable
    true
  end

end