class TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::Nothotaxon < TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000388'

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate)
  end

end
