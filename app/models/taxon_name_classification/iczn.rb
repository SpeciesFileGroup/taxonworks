class TaxonNameClassification::Iczn < TaxonNameClassification

  def self.code_applicability_start_year
    1758
  end

  def self.disjoint_taxon_name_classes
    self.collect_descendants_to_s(TaxonNameClassification::Icn)
  end

end
