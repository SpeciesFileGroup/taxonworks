class TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate < TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished) + self.collect_descendants_and_itself_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate)
  end

end
