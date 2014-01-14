class TaxonNameClassification::Iczn::Available::Valid::NomenDubium < TaxonNameClassification::Iczn::Available::Valid

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClassification::Iczn::Available::Valid.to_s]
  end

end
