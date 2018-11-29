class TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Legitimate::Incorrect < TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Legitimate

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000088'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Legitimate,
        TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Legitimate::Correct)
  end

  def self.gbif_status
    'invalidum'
  end

end
