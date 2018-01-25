class TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Legitimate < TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000086'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished.to_s] +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Illegitimate)
  end

  def self.gbif_status
    'legitimate'
  end

end
