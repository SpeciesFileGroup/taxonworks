class TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate < TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000386'

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished.to_s] +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate)
  end

  def self.gbif_status
    'illegitimum'
  end

end
