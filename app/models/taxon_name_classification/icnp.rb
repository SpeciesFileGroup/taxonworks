class TaxonNameClassification::Icnp < TaxonNameClassification

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000110'.freeze

  def self.applicable_ranks
    ICNP
  end

  def self.disjoint_taxon_name_classes
    ICZN_TAXON_NAME_CLASSIFICATION_NAMES + ICN_TAXON_NAME_CLASSIFICATION_NAMES + ICVCN_TAXON_NAME_CLASSIFICATION_NAMES
  end

end
