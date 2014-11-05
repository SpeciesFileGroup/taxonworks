class TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::Incorrect < TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate,
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::Correct)
  end

  def self.gbif_status
    'invalidum'
  end

end
