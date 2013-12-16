class TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::AdoptedByFries < TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Legitimate

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Legitimate.to_s] +
        [TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Legitimate::AdoptedByPersoon.to_s]
  end

end
