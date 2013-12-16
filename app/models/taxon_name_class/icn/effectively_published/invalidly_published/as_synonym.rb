class TaxonNameClass::Icn::EffectivelyPublished::InvalidlyPublished::AsSynonym < TaxonNameClass::Icn::EffectivelyPublished::InvalidlyPublished

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClass::Icn::EffectivelyPublished::InvalidlyPublished.to_s]
  end

end