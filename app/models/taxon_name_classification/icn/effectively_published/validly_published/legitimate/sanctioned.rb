class TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::Sanctioned < TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate.to_s] +
        [TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::Conserved.to_s]
  end

end
