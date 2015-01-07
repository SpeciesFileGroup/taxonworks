class TaxonNameClassification::Iczn < TaxonNameClassification

  def self.applicable_ranks
   ICZN 
  end

  def self.code_applicability_start_year
    1758
  end

  def self.disjoint_taxon_name_classes
    ICN_TAXON_NAME_CLASSIFICATION_NAMES
  end

end
