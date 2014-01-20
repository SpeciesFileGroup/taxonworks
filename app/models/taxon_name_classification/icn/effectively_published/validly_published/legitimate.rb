class TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate < TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished) +
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate.descendants.collect{|t| t.to_s} +
        [TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate.to_s]
  end

end
