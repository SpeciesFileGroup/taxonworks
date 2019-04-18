class TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Legitimate::OfficialList < TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Legitimate

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000103'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Legitimate,
        TaxonNameClassification::Icnp::EffectivelyPublished::ValidlyPublished::Legitimate::Candidatus)
  end

end
