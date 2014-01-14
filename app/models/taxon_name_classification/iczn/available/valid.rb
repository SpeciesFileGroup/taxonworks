class TaxonNameClassification::Iczn::Available::Valid < TaxonNameClassification::Iczn::Available

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClassification::Iczn::Available::Invalid.to_s]
  end

end
