class TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished < TaxonNameClassification::Icn::EffectivelyPublished

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished) +
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished.to_s]
  end

end