class TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::Correct < TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000010'

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate,
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::Incorrect)
  end

  def self.gbif_status
    'valid'
  end

end
