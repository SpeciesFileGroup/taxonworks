class TaxonNameClassification::Iczn::Available::Invalid < TaxonNameClassification::Iczn::Available

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClassification::Iczn::Available::Valid.to_s]
  end

end
