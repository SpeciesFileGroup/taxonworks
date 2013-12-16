class TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate::Homonym < TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate.to_s] +
        [TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate::IncorrectOriginalSpelling.to_s] +
        [TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate::Superfluous.to_s]
  end

end
