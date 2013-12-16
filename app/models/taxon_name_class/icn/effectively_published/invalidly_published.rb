class TaxonNameClass::Icn::EffectivelyPublished::InvalidlyPublished < TaxonNameClass::Icn::EffectivelyPublished

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClass::Icn::EffectivelyPublished.to_s] +
        TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished.to_s]
  end

end