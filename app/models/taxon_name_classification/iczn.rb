class TaxonNameClassification::Iczn < TaxonNameClassification

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000107'.freeze

  def self.applicable_ranks
    ICZN
  end

  def self.code_applicability_start_year
    1758
  end

  def self.disjoint_taxon_name_classes
    ICNP_TAXON_NAME_CLASSIFICATION_NAMES + ICN_TAXON_NAME_CLASSIFICATION_NAMES + ICVCN_TAXON_NAME_CLASSIFICATION_NAMES
  end

end
