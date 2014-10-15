class TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate < TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished.to_s] +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate)
  end

  def self.gbif_status
    'legitimate'
  end

end
