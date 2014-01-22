class TaxonNameClassification::Icn::EffectivelyPublished < TaxonNameClassification::Icn

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_descendants_and_itself_to_s(
        TaxonNameClassification::Icn::NotEffectivelyPublished)
  end

end