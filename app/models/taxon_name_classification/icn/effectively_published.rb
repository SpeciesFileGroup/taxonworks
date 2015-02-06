class TaxonNameClassification::Icn::EffectivelyPublished < TaxonNameClassification::Icn

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000383'

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_descendants_and_itself_to_s(
        TaxonNameClassification::Icn::NotEffectivelyPublished)
  end

end