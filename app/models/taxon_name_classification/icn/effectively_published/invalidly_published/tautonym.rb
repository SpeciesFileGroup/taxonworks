class TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished::Tautonym < TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClassification::Icn::EffectivelyPublished::InvalidlyPublished.to_s]
  end

end
