class TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate::Superfluous < TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate.to_s] +
        [TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate::IncorrectOriginalSpelling.to_s] +
        [TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate::Homonym.to_s]
  end

end
