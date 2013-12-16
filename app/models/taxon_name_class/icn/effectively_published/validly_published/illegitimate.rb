class TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate < TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished.to_s] +
        TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Legitimate.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Legitimate.to_s]
  end

end
