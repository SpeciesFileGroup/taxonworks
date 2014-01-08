class TaxonNameClassification::Iczn < TaxonNameClassification

  def self.code_applicability_start_year
    1758
  end

  def self.disjoint_taxon_name_classes
    TaxonNameClassification::Icn.descendants.collect{|t| t.to_s}
  end

end
