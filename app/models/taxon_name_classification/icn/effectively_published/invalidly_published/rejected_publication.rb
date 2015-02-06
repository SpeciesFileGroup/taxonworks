class TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished::RejectedPublication < TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000380'

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished)
  end

  def self.gbif_status
    'oppressa'
  end

end
