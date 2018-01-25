class TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Illegitimate::Rejected < TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Illegitimate

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000104'.freeze

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Illegitimate,
        TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Illegitimate::NotInOfficialList,
        TaxonNameClassification::Icnb::EffectivelyPublished::ValidlyPublished::Illegitimate::Homonym)
  end

  def self.gbif_status
    'rejiciendum'
  end

end