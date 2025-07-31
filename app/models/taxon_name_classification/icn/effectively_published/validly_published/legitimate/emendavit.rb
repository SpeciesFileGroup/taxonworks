class TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::Emendavit < TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0003000'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
      TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate)
  end

  def classification_label
    'emend.'
  end

end
