class TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished < TaxonNameClassification::Icn::EffectivelyPublished

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished) +
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished.to_s]
  end

end