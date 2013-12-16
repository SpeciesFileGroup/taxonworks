class TaxonNameClass::Icn::EffectivelyPublished::ValidlyPublished < TaxonNameClass::Icn::EffectivelyPublished

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClass::Icn::EffectivelyPublished.to_s] +
        TaxonNameClass::Icn::EffectivelyPublished::InvalidlyPublished.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Icn::EffectivelyPublished::InvalidlyPublished.to_s]
  end

end