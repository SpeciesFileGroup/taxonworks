class TaxonNameClassification::Icnb::EffectivelyPublished::InvalidlyPublished < TaxonNameClassification::Icnb::EffectivelyPublished

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000083'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClassification::Icnb::EffectivelyPublished.to_s] +
        self.collect_descendants_and_itself_to_s(TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished)
  end

  def self.gbif_status
    'invalidum'
  end

end