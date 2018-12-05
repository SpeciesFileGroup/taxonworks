class TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Illegitimate < TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000085'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished.to_s] +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Legitimate)
  end

  def self.gbif_status
    'illegitimum'
  end

end
