class TaxonNameClassification::Icn::NotEffectivelyPublished < TaxonNameClassification::Icn

  def self.applicable_ranks
    ICN.collect{|t| t.to_s}
  end

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_descendants_and_itself_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished)
  end

end