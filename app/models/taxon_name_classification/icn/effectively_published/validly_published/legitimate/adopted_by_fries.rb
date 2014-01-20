class TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::AdoptedByFries < TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate,
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::AdoptedByPersoon)
  end

end
