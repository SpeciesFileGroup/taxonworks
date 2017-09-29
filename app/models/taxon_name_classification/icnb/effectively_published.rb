class TaxonNameClassification::Icnb::EffectivelyPublished < TaxonNameClassification::Icnb

  NOMEN_URI='http://purl.obolibrary.org/obo/NOMEN_0000081'

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_descendants_and_itself_to_s(
        TaxonNameClassification::Icnb::NotEffectivelyPublished)
  end

  def self.assignable
    true
  end

end
