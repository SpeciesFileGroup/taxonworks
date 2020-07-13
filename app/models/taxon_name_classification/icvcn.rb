class TaxonNameClassification::Icvcn < TaxonNameClassification

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000111'.freeze

  def self.applicable_ranks
    ICTV
  end

  def self.disjoint_taxon_name_classes
    ICZN_TAXON_NAME_CLASSIFICATION_NAMES + ICN_TAXON_NAME_CLASSIFICATION_NAMES + ICNP_TAXON_NAME_CLASSIFICATION_NAMES
  end

end