class TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate::Homonym < TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes + self.collect_to_s(
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate,
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate::IncorrectOriginalSpelling,
        TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate::Superfluous)
  end

end
