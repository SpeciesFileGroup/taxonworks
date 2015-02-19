class TaxonNameClassification::Latinized < TaxonNameClassification

  validates_uniqueness_of :taxon_name_id

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000032'

end