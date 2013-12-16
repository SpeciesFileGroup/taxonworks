class TaxonNameClass::Iczn::Available::Valid::NomenDubium < TaxonNameClass::Iczn::Available::Valid

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        [TaxonNameClass::Iczn::Available::Valid.to_s]
  end

end
