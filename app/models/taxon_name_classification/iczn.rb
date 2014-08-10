class TaxonNameClassification::Iczn < TaxonNameClassification

  def self.applicable_ranks
   ICZN # ICZN.collect{|t| t.to_s}
  end

  def self.code_applicability_start_year
    1758
  end

  def self.disjoint_taxon_name_classes
    ICN_TAXON_NAME_CLASS_NAMES
  end

end
