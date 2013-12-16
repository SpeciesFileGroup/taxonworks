class TaxonNameClass::Iczn::Unavailable::Suppressed < TaxonNameClass::Iczn::Unavailable

  def self.disjoint_taxon_name_classes
    self.parent.disjoint_taxon_name_classes +
        TaxonNameClass::Iczn::Unavailable::Excluded.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Iczn::Unavailable::Excluded.to_s] +
        TaxonNameClass::Iczn::Unavailable::NomenNudum.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Iczn::Unavailable::NomenNudum.to_s] +
        TaxonNameClass::Iczn::Unavailable::NotBinomial.descendants.collect{|t| t.to_s} +
        [TaxonNameClass::Iczn::Unavailable::NotBinomial.to_s]
  end

end
