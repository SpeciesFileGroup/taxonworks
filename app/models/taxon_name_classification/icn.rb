class TaxonNameClassification::Icn < TaxonNameClassification

  def self.applicable_ranks
    RANK_CLASS_NAMES_ICN
  end

  def self.disjoint_taxon_name_classes
    self.collect_descendants_to_s(TaxonNameClassification::Iczn)
  end

end
