class TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Legitimate < TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished.to_s] +
        TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished::Illegitimate.to_s]
  end

end
