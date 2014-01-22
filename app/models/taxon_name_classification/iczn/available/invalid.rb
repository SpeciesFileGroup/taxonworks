class TaxonNameClassification::Iczn::Available::Invalid < TaxonNameClassification::Iczn::Available

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        self.collect_to_s(TaxonNameClassification::Iczn::Available::Valid)
  end

end
