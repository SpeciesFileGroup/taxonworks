class TaxonNameClassification::Icn < TaxonNameClassification

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000109'.freeze

  def self.applicable_ranks
    # RANK_CLASS_NAMES_ICN
    ICN 
  end

  def self.disjoint_taxon_name_classes
    ICZN_TAXON_NAME_CLASSIFICATION_NAMES + ICNP_TAXON_NAME_CLASSIFICATION_NAMES + ICVCN_TAXON_NAME_CLASSIFICATION_NAMES
  end

end
