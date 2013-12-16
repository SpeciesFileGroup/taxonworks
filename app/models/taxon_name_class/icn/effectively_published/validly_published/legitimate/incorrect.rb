class TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::Incorrect < TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Legitimate

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Legitimate.to_s] +
        [TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::Correct.to_s]
  end

end
