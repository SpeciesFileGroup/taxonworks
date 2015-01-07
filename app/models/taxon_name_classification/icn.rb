class TaxonNameClassification::Icn < TaxonNameClassification

  def self.applicable_ranks
    # RANK_CLASS_NAMES_ICN
    ICN 
  end

  def self.disjoint_taxon_name_classes
   ICZN_TAXON_NAME_CLASSIFICATION_NAMES
    # ICZN_TAXON_NAME_CLASS_NAMES
  end

end
