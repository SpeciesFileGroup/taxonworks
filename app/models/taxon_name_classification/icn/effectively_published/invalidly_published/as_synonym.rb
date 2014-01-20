class TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished::AsSynonym < TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished)
  end

end