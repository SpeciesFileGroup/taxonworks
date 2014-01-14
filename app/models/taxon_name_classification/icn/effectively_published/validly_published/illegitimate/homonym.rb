class TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate::Homonym < TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate.to_s] +
        [TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate::IncorrectOriginalSpelling.to_s] +
        [TaxonNameClassification::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate::Superfluous.to_s]
  end

end
